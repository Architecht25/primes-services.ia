import { Controller } from "@hotwired/stimulus"

// Contrôleur Stimulus pour les fonctionnalités PWA
export default class extends Controller {
  static targets = ["installButton", "status", "banner"]
  static values = {
    installPromptDelay: { type: Number, default: 3000 },
    showInstallPrompt: { type: Boolean, default: true }
  }

  deferredPrompt = null
  isInstalled = false

  connect() {
    console.log("PWA controller connected")

    this.checkPWAStatus()
    this.setupInstallPrompt()
    this.setupAppUpdateHandler()
  }

  // Vérifier le statut PWA
  checkPWAStatus() {
    // Vérifier si déjà installé
    if (window.matchMedia('(display-mode: standalone)').matches ||
        window.navigator.standalone ||
        document.referrer.includes('android-app://')) {
      this.isInstalled = true
      this.onAppInstalled()
    }

    // Vérifier le support du service worker
    if ('serviceWorker' in navigator) {
      this.registerServiceWorker()
    } else {
      console.warn("Service Worker non supporté")
    }
  }

  // Enregistrer le service worker
  async registerServiceWorker() {
    try {
      const registration = await navigator.serviceWorker.register('/pwa/service-worker.js')
      console.log('Service Worker enregistré:', registration)

      // Écouter les mises à jour
      registration.addEventListener('updatefound', () => {
        this.onServiceWorkerUpdate(registration)
      })

      // Vérifier les mises à jour
      registration.update()

      this.updateStatus("Application prête à fonctionner hors ligne")
    } catch (error) {
      console.error('Erreur enregistrement Service Worker:', error)
      this.updateStatus("Erreur configuration mode hors ligne")
    }
  }

  // Gérer les mises à jour du service worker
  onServiceWorkerUpdate(registration) {
    const newWorker = registration.installing

    newWorker.addEventListener('statechange', () => {
      if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
        this.showUpdateAvailable()
      }
    })
  }

  // Configurer le prompt d'installation
  setupInstallPrompt() {
    window.addEventListener('beforeinstallprompt', (e) => {
      console.log('Événement beforeinstallprompt reçu')

      // Empêcher l'affichage automatique
      e.preventDefault()

      // Sauvegarder l'événement pour usage ultérieur
      this.deferredPrompt = e

      // Afficher le bouton d'installation avec délai
      if (this.showInstallPromptValue) {
        setTimeout(() => {
          this.showInstallButton()
        }, this.installPromptDelayValue)
      }
    })

    // Écouter l'installation
    window.addEventListener('appinstalled', () => {
      console.log('PWA installée avec succès')
      this.onAppInstalled()
    })
  }

  // Configurer la gestion des mises à jour d'app
  setupAppUpdateHandler() {
    // Écouter les changements de visibilité pour vérifier les mises à jour
    document.addEventListener('visibilitychange', () => {
      if (!document.hidden && 'serviceWorker' in navigator) {
        navigator.serviceWorker.getRegistration()
          .then(registration => {
            if (registration) {
              registration.update()
            }
          })
      }
    })
  }

  // Afficher le bouton d'installation
  showInstallButton() {
    if (this.hasInstallButtonTarget && !this.isInstalled) {
      this.installButtonTarget.classList.remove('hidden')

      if (this.hasBannerTarget) {
        this.bannerTarget.classList.remove('hidden')
      }
    }
  }

  // Masquer le bouton d'installation
  hideInstallButton() {
    if (this.hasInstallButtonTarget) {
      this.installButtonTarget.classList.add('hidden')
    }

    if (this.hasBannerTarget) {
      this.bannerTarget.classList.add('hidden')
    }
  }

  // Action: installer l'application
  async install() {
    if (!this.deferredPrompt) {
      this.updateStatus("Installation non disponible")
      return
    }

    try {
      // Afficher le prompt d'installation
      this.deferredPrompt.prompt()

      // Attendre la réponse utilisateur
      const { outcome } = await this.deferredPrompt.userChoice

      console.log(`Résultat installation: ${outcome}`)

      if (outcome === 'accepted') {
        this.updateStatus("Installation en cours...")
      } else {
        this.updateStatus("Installation annulée")
      }

      // Nettoyer la référence
      this.deferredPrompt = null

    } catch (error) {
      console.error('Erreur installation PWA:', error)
      this.updateStatus("Erreur lors de l'installation")
    }
  }

  // Action: fermer la bannière d'installation
  dismissInstallPrompt() {
    this.hideInstallButton()

    // Sauvegarder la préférence
    localStorage.setItem('pwa-install-dismissed', Date.now().toString())
  }

  // Application installée avec succès
  onAppInstalled() {
    this.isInstalled = true
    this.hideInstallButton()
    this.updateStatus("Application installée avec succès!")

    // Déclencher un événement personnalisé
    this.dispatch("appInstalled")

    // Configurer les fonctionnalités post-installation
    this.setupPostInstallFeatures()
  }

  // Configurer les fonctionnalités post-installation
  setupPostInstallFeatures() {
    // Demander l'autorisation pour les notifications
    this.requestNotificationPermission()

    // Configurer la synchronisation en arrière-plan
    this.setupBackgroundSync()
  }

  // Demander l'autorisation pour les notifications
  async requestNotificationPermission() {
    if ('Notification' in window && 'serviceWorker' in navigator) {
      const permission = await Notification.requestPermission()

      if (permission === 'granted') {
        this.updateStatus("Notifications activées")
        this.setupPushNotifications()
      }
    }
  }

  // Configurer les notifications push
  async setupPushNotifications() {
    try {
      const registration = await navigator.serviceWorker.ready

      // S'abonner aux notifications push
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(this.vapidPublicKey)
      })

      // Envoyer l'abonnement au serveur
      await this.sendSubscriptionToServer(subscription)

    } catch (error) {
      console.error('Erreur configuration notifications push:', error)
    }
  }

  // Configurer la synchronisation en arrière-plan
  setupBackgroundSync() {
    if ('serviceWorker' in navigator && 'sync' in window.ServiceWorkerRegistration.prototype) {
      console.log('Synchronisation en arrière-plan disponible')

      // Enregistrer la synchronisation des soumissions offline
      navigator.serviceWorker.ready.then(registration => {
        return registration.sync.register('sync-offline-submissions')
      })
    }
  }

  // Afficher une mise à jour disponible
  showUpdateAvailable() {
    if (confirm('Une nouvelle version de l\'application est disponible. Voulez-vous la mettre à jour ?')) {
      this.applyUpdate()
    }
  }

  // Appliquer la mise à jour
  applyUpdate() {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistration().then(registration => {
        if (registration && registration.waiting) {
          registration.waiting.postMessage({ action: 'skipWaiting' })

          // Recharger la page pour appliquer la mise à jour
          window.location.reload()
        }
      })
    }
  }

  // Mise à jour du statut
  updateStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      this.statusTarget.classList.remove('hidden')

      // Masquer automatiquement après 3 secondes
      setTimeout(() => {
        this.statusTarget.classList.add('hidden')
      }, 3000)
    }

    console.log("PWA status:", message)
  }

  // Utilitaires

  urlBase64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding)
      .replace(/-/g, '+')
      .replace(/_/g, '/')

    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }

  async sendSubscriptionToServer(subscription) {
    try {
      const response = await fetch('/pwa/subscribe_notifications', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({ subscription: subscription })
      })

      if (response.ok) {
        console.log('Abonnement notifications envoyé au serveur')
      }
    } catch (error) {
      console.error('Erreur envoi abonnement:', error)
    }
  }

  get vapidPublicKey() {
    // Clé publique VAPID pour les notifications push
    // À configurer avec votre vraie clé
    return 'BK8N0l8Y....' // Placeholder
  }
}

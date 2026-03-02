import { Controller } from "@hotwired/stimulus"

// Contrôleur Stimulus pour la gestion du mode hors ligne
export default class extends Controller {
  static targets = ["status", "indicator", "form", "submitButton", "offlineQueue"]
  static values = {
    checkInterval: { type: Number, default: 5000 },
    enableAutoSync: { type: Boolean, default: true }
  }

  isOnline = navigator.onLine
  offlineSubmissions = []
  checkIntervalId = null

  connect() {
    console.log("Offline controller connected")

    this.updateConnectionStatus()
    this.setupEventListeners()
    this.startConnectionMonitoring()
    this.loadOfflineQueue()
  }

  disconnect() {
    this.stopConnectionMonitoring()
  }

  // Configuration des écouteurs d'événements
  setupEventListeners() {
    // Écouter les changements de statut réseau
    window.addEventListener('online', () => this.onOnline())
    window.addEventListener('offline', () => this.onOffline())

    // Écouter les soumissions de formulaires
    if (this.hasFormTarget) {
      this.formTarget.addEventListener('submit', (e) => this.handleFormSubmit(e))
    }

    // Écouter la synchronisation du service worker
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.addEventListener('message', (event) => {
        if (event.data.action === 'sync-complete') {
          this.onSyncComplete()
        }
      })
    }
  }

  // Démarrer la surveillance de connexion
  startConnectionMonitoring() {
    this.checkIntervalId = setInterval(() => {
      this.checkConnection()
    }, this.checkIntervalValue)
  }

  // Arrêter la surveillance de connexion
  stopConnectionMonitoring() {
    if (this.checkIntervalId) {
      clearInterval(this.checkIntervalId)
      this.checkIntervalId = null
    }
  }

  // Vérifier la connexion réseau
  async checkConnection() {
    try {
      // Tenter une requête légère vers le serveur
      const response = await fetch('/ping', {
        method: 'HEAD',
        cache: 'no-cache',
        signal: AbortSignal.timeout(3000)
      })

      const wasOnline = this.isOnline
      this.isOnline = response.ok

      if (!wasOnline && this.isOnline) {
        this.onOnline()
      } else if (wasOnline && !this.isOnline) {
        this.onOffline()
      }

    } catch (error) {
      if (this.isOnline) {
        this.isOnline = false
        this.onOffline()
      }
    }
  }

  // Connexion rétablie
  onOnline() {
    console.log("Connexion rétablie")
    this.isOnline = true
    this.updateConnectionStatus()

    if (this.enableAutoSyncValue) {
      this.syncOfflineSubmissions()
    }

    this.showNotification("Connexion rétablie", "success")
  }

  // Connexion perdue
  onOffline() {
    console.log("Connexion perdue")
    this.isOnline = false
    this.updateConnectionStatus()

    this.showNotification("Mode hors ligne activé", "warning")
  }

  // Mettre à jour l'affichage du statut de connexion
  updateConnectionStatus() {
    // Mettre à jour l'indicateur de statut
    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.toggle('online', this.isOnline)
      this.indicatorTarget.classList.toggle('offline', !this.isOnline)
    }

    // Mettre à jour le texte de statut
    if (this.hasStatusTarget) {
      const statusText = this.isOnline ?
        "En ligne" :
        "Hors ligne - Les données seront synchronisées dès la reconnexion"

      this.statusTarget.textContent = statusText
      this.statusTarget.className = `status ${this.isOnline ? 'online' : 'offline'}`
    }

    // Adapter l'interface utilisateur
    this.adaptUIForConnection()
  }

  // Adapter l'interface selon le statut de connexion
  adaptUIForConnection() {
    if (this.hasSubmitButtonTarget) {
      const button = this.submitButtonTarget

      if (this.isOnline) {
        button.textContent = button.dataset.onlineText || "Envoyer"
        button.disabled = false
      } else {
        button.textContent = button.dataset.offlineText || "Sauvegarder (hors ligne)"
        button.disabled = false // Garder actif pour stockage offline
      }
    }

    // Afficher/masquer la queue offline
    this.updateOfflineQueueDisplay()
  }

  // Gérer la soumission de formulaires
  async handleFormSubmit(event) {
    if (!this.isOnline) {
      event.preventDefault()
      await this.storeOfflineSubmission(event.target)
      return false
    }

    // Laisser la soumission normale se faire si en ligne
    return true
  }

  // Stocker une soumission pour synchronisation ultérieure
  async storeOfflineSubmission(form) {
    try {
      const formData = new FormData(form)
      const submission = {
        id: this.generateSubmissionId(),
        url: form.action,
        method: form.method || 'POST',
        data: Object.fromEntries(formData),
        timestamp: Date.now(),
        formType: form.dataset.formType || 'unknown'
      }

      this.offlineSubmissions.push(submission)
      this.saveOfflineQueue()
      this.updateOfflineQueueDisplay()

      this.showNotification("Données sauvegardées pour envoi ultérieur", "info")

      // Déclencher un événement personnalisé
      this.dispatch("submissionStored", { detail: submission })

      // Nettoyer le formulaire si demandé
      if (form.dataset.clearOnStore === 'true') {
        form.reset()
      }

    } catch (error) {
      console.error('Erreur stockage offline:', error)
      this.showNotification("Erreur lors de la sauvegarde", "error")
    }
  }

  // Synchroniser les soumissions offline
  async syncOfflineSubmissions() {
    if (this.offlineSubmissions.length === 0) {
      return
    }

    this.showNotification("Synchronisation en cours...", "info")

    const syncResults = []

    for (const submission of this.offlineSubmissions) {
      try {
        const formData = new FormData()
        Object.entries(submission.data).forEach(([key, value]) => {
          formData.append(key, value)
        })

        const response = await fetch(submission.url, {
          method: submission.method,
          body: formData
        })

        if (response.ok) {
          syncResults.push({ submission, success: true })
        } else {
          syncResults.push({ submission, success: false, error: `HTTP ${response.status}` })
        }

      } catch (error) {
        syncResults.push({ submission, success: false, error: error.message })
      }
    }

    // Traiter les résultats
    const successful = syncResults.filter(r => r.success)
    const failed = syncResults.filter(r => !r.success)

    // Supprimer les soumissions réussies
    this.offlineSubmissions = this.offlineSubmissions.filter(sub =>
      !successful.some(s => s.submission.id === sub.id)
    )

    this.saveOfflineQueue()
    this.updateOfflineQueueDisplay()

    // Notifier les résultats
    if (successful.length > 0) {
      this.showNotification(`${successful.length} envoi(s) synchronisé(s)`, "success")
    }

    if (failed.length > 0) {
      this.showNotification(`${failed.length} envoi(s) en échec`, "error")
    }

    // Déclencher un événement personnalisé
    this.dispatch("syncComplete", {
      detail: { successful: successful.length, failed: failed.length }
    })
  }

  // Action: synchronisation manuelle
  manualSync() {
    if (this.isOnline) {
      this.syncOfflineSubmissions()
    } else {
      this.showNotification("Synchronisation impossible - pas de connexion", "warning")
    }
  }

  // Action: vider la queue offline
  clearOfflineQueue() {
    if (confirm('Êtes-vous sûr de vouloir supprimer toutes les données en attente ?')) {
      this.offlineSubmissions = []
      this.saveOfflineQueue()
      this.updateOfflineQueueDisplay()
      this.showNotification("Queue offline vidée", "info")
    }
  }

  // Mettre à jour l'affichage de la queue offline
  updateOfflineQueueDisplay() {
    if (this.hasOfflineQueueTarget) {
      const count = this.offlineSubmissions.length

      if (count > 0) {
        this.offlineQueueTarget.textContent = `${count} envoi(s) en attente`
        this.offlineQueueTarget.classList.remove('hidden')
      } else {
        this.offlineQueueTarget.classList.add('hidden')
      }
    }
  }

  // Charger la queue offline depuis le stockage local
  loadOfflineQueue() {
    try {
      const stored = localStorage.getItem('offline-submissions')
      if (stored) {
        this.offlineSubmissions = JSON.parse(stored)
        this.updateOfflineQueueDisplay()
      }
    } catch (error) {
      console.error('Erreur chargement queue offline:', error)
      this.offlineSubmissions = []
    }
  }

  // Sauvegarder la queue offline dans le stockage local
  saveOfflineQueue() {
    try {
      localStorage.setItem('offline-submissions', JSON.stringify(this.offlineSubmissions))
    } catch (error) {
      console.error('Erreur sauvegarde queue offline:', error)
    }
  }

  // Callback de synchronisation complète du service worker
  onSyncComplete() {
    this.loadOfflineQueue() // Recharger depuis le service worker
    this.showNotification("Synchronisation automatique terminée", "success")
  }

  // Afficher une notification
  showNotification(message, type = "info") {
    // Créer une notification temporaire
    const notification = document.createElement('div')
    notification.className = `notification notification-${type}`
    notification.textContent = message

    // Ajouter au DOM
    document.body.appendChild(notification)

    // Supprimer après 3 secondes
    setTimeout(() => {
      notification.remove()
    }, 3000)

    console.log(`[Offline] ${type.toUpperCase()}: ${message}`)
  }

  // Générer un ID unique pour les soumissions
  generateSubmissionId() {
    return `submission-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
  }
}

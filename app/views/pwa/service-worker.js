// Service Worker pour Primes Services IA
// Gère le cache, mode offline, et notifications push

const CACHE_NAME = 'primes-services-cache-v1'
const OFFLINE_CACHE_NAME = 'primes-services-offline-v1'

// URLs à mettre en cache pour fonctionnement offline
const urlsToCache = [
  '/',
  '/pages/home',
  '/pages/about',
  '/contacts/particulier',
  '/contacts/acp',
  '/contacts/entreprise_immo',
  '/contacts/entreprise_comm',
  '/pwa/offline',
  '/assets/application.css',
  '/assets/application.js',
  '/icon.png'
]

// Installation du Service Worker
self.addEventListener('install', (event) => {
  console.log('[SW] Installation en cours...')

  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[SW] Cache ouvert')
        return cache.addAll(urlsToCache)
      })
      .then(() => {
        console.log('[SW] URLs mises en cache')
        return self.skipWaiting()
      })
  )
})

// Activation du Service Worker
self.addEventListener('activate', (event) => {
  console.log('[SW] Activation en cours...')

  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME && cacheName !== OFFLINE_CACHE_NAME) {
            console.log('[SW] Suppression ancien cache:', cacheName)
            return caches.delete(cacheName)
          }
        })
      )
    }).then(() => {
      console.log('[SW] Service Worker activé')
      return self.clients.claim()
    })
  )
})

// Interception des requêtes réseau
self.addEventListener('fetch', (event) => {
  // Stratégie Cache First pour les assets statiques
  if (event.request.destination === 'style' ||
      event.request.destination === 'script' ||
      event.request.destination === 'image') {

    event.respondWith(
      caches.match(event.request)
        .then((response) => {
          return response || fetch(event.request)
        })
    )
    return
  }

  // Stratégie Network First pour les pages HTML
  if (event.request.destination === 'document') {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          // Mettre en cache la réponse
          const responseClone = response.clone()
          caches.open(CACHE_NAME)
            .then((cache) => {
              cache.put(event.request, responseClone)
            })
          return response
        })
        .catch(() => {
          // En cas d'échec réseau, servir depuis le cache ou page offline
          return caches.match(event.request)
            .then((response) => {
              return response || caches.match('/pwa/offline')
            })
        })
    )
    return
  }

  // Gestion des soumissions de formulaires en mode offline
  if (event.request.method === 'POST' && event.request.url.includes('/contacts')) {
    event.respondWith(
      fetch(event.request.clone())
        .catch(() => {
          // Stocker la soumission pour synchronisation ultérieure
          return storeOfflineSubmission(event.request.clone())
        })
    )
    return
  }

  // Stratégie par défaut
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        return response || fetch(event.request)
      })
  )
})

// Synchronisation en arrière-plan
self.addEventListener('sync', (event) => {
  console.log('[SW] Synchronisation en arrière-plan:', event.tag)

  if (event.tag === 'sync-offline-submissions') {
    event.waitUntil(syncOfflineSubmissions())
  }
})

// Gestion des notifications push
self.addEventListener("push", async (event) => {
  console.log('[SW] Notification push reçue')

  try {
    const data = event.data ? event.data.json() : {}
    const title = data.title || "Primes Services IA"
    const options = {
      body: data.body || "Une nouvelle notification",
      icon: data.icon || "/icon.png",
      badge: "/icon.png",
      data: data.data || { url: "/" },
      tag: data.tag || 'default',
      requireInteraction: data.requireInteraction || false,
      actions: data.actions || []
    }

    event.waitUntil(self.registration.showNotification(title, options))
  } catch (e) {
    console.error('[SW] Erreur notification push:', e)
  }
})

// Gestion des clics sur notifications
self.addEventListener("notificationclick", function(event) {
  console.log('[SW] Clic sur notification')

  event.notification.close()

  const urlToOpen = event.notification.data?.url || '/'

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true })
      .then((clientList) => {
        // Chercher une fenêtre existante avec la même URL
        for (let i = 0; i < clientList.length; i++) {
          let client = clientList[i]
          let clientPath = (new URL(client.url)).pathname
          let targetPath = (new URL(urlToOpen, self.location.origin)).pathname

          if (clientPath === targetPath && "focus" in client) {
            return client.focus()
          }
        }

        // Ouvrir une nouvelle fenêtre si aucune correspondance
        if (clients.openWindow) {
          return clients.openWindow(urlToOpen)
        }
      })
  )
})

// Fonctions utilitaires

async function storeOfflineSubmission(request) {
  try {
    const formData = await request.formData()
    const submission = {
      url: request.url,
      method: request.method,
      data: Object.fromEntries(formData),
      timestamp: Date.now()
    }

    // Stocker dans IndexedDB ou localStorage
    const cache = await caches.open(OFFLINE_CACHE_NAME)
    const response = new Response(JSON.stringify(submission))
    await cache.put(`offline-submission-${Date.now()}`, response)

    // Programmer une synchronisation
    self.registration.sync.register('sync-offline-submissions')

    return new Response('Soumission stockée pour synchronisation', {
      status: 202,
      statusText: 'Accepted'
    })
  } catch (e) {
    console.error('[SW] Erreur stockage offline:', e)
    return new Response('Erreur de stockage', { status: 500 })
  }
}

async function syncOfflineSubmissions() {
  try {
    const cache = await caches.open(OFFLINE_CACHE_NAME)
    const requests = await cache.keys()

    for (const request of requests) {
      if (request.url.includes('offline-submission')) {
        const response = await cache.match(request)
        const submission = await response.json()

        // Tenter de renvoyer la soumission
        const formData = new FormData()
        Object.entries(submission.data).forEach(([key, value]) => {
          formData.append(key, value)
        })

        try {
          const result = await fetch(submission.url, {
            method: submission.method,
            body: formData
          })

          if (result.ok) {
            // Supprimer du cache si succès
            await cache.delete(request)
            console.log('[SW] Soumission synchronisée avec succès')
          }
        } catch (e) {
          console.log('[SW] Échec synchronisation, retry plus tard')
        }
      }
    }
  } catch (e) {
    console.error('[SW] Erreur synchronisation:', e)
  }
}

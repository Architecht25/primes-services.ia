class PwaCacheService
  # Service pour gérer le cache PWA et les fonctionnalités offline

  CACHE_NAME = 'primes-services-cache-v1'
  OFFLINE_CACHE_NAME = 'primes-services-offline-v1'

  # URLs à mettre en cache pour fonctionnement offline
  CACHE_URLS = [
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
  ].freeze

  # Données critiques à mettre en cache (primes, régions, etc.)
  CRITICAL_DATA = {
    regions: ['wallonie', 'flandre', 'bruxelles'],
    prime_types: ['isolation', 'chauffage', 'photovoltaique', 'audit_energetique'],
    contact_types: ['particulier', 'acp', 'entreprise_immo', 'entreprise_comm']
  }.freeze

  class << self
    def cache_essential_data
      # Met en cache les données essentielles pour le mode offline
      cache_data = {
        timestamp: Time.current.iso8601,
        regions: CRITICAL_DATA[:regions],
        prime_types: CRITICAL_DATA[:prime_types],
        contact_types: CRITICAL_DATA[:contact_types],
        basic_primes_info: generate_basic_primes_info
      }

      Rails.cache.write('pwa_essential_data', cache_data, expires_in: 1.day)
      cache_data
    end

    def get_cached_data
      # Récupère les données mises en cache
      Rails.cache.fetch('pwa_essential_data') do
        cache_essential_data
      end
    end

    def cache_form_data(form_type, data)
      # Met en cache les données de formulaire en cours de saisie
      cache_key = "form_draft_#{form_type}_#{data[:session_id] || 'anonymous'}"
      Rails.cache.write(cache_key, data, expires_in: 24.hours)
    end

    def get_cached_form_data(form_type, session_id = nil)
      # Récupère les données de formulaire en cache
      cache_key = "form_draft_#{form_type}_#{session_id || 'anonymous'}"
      Rails.cache.read(cache_key)
    end

    def clear_form_cache(form_type, session_id = nil)
      # Supprime les données de formulaire du cache
      cache_key = "form_draft_#{form_type}_#{session_id || 'anonymous'}"
      Rails.cache.delete(cache_key)
    end

    def sync_offline_submissions
      # Synchronise les soumissions effectuées en mode offline
      offline_submissions = Rails.cache.read('offline_submissions') || []

      offline_submissions.each do |submission|
        begin
          # Tenter de soumettre les données
          contact = ContactSubmission.create!(submission[:data])

          # Envoyer l'email si réussi
          EmailService.send_contact_notification(contact) if contact.persisted?

          # Marquer comme synchronisé
          submission[:synced] = true
          submission[:synced_at] = Time.current
        rescue => e
          Rails.logger.error "Erreur synchronisation offline: #{e.message}"
          submission[:error] = e.message
        end
      end

      # Nettoyer les soumissions synchronisées
      remaining_submissions = offline_submissions.reject { |s| s[:synced] }
      Rails.cache.write('offline_submissions', remaining_submissions)

      {
        total: offline_submissions.size,
        synced: offline_submissions.count { |s| s[:synced] },
        remaining: remaining_submissions.size
      }
    end

    def store_offline_submission(form_data)
      # Stocke une soumission effectuée en mode offline
      offline_submissions = Rails.cache.read('offline_submissions') || []

      submission = {
        id: SecureRandom.uuid,
        data: form_data,
        created_at: Time.current,
        synced: false
      }

      offline_submissions << submission
      Rails.cache.write('offline_submissions', offline_submissions)

      submission
    end

    def generate_service_worker_config
      # Génère la configuration pour le service worker
      {
        cache_name: CACHE_NAME,
        offline_cache_name: OFFLINE_CACHE_NAME,
        cache_urls: CACHE_URLS,
        version: cache_version,
        sync_enabled: true
      }
    end

    private

    def generate_basic_primes_info
      # Génère des informations de base sur les primes pour le cache offline
      {
        wallonie: {
          isolation: { min: 1000, max: 6000 },
          chauffage: { min: 500, max: 4000 },
          photovoltaique: { min: 2500, max: 15000 }
        },
        flandre: {
          isolation: { min: 800, max: 5000 },
          chauffage: { min: 400, max: 3500 },
          photovoltaique: { min: 2000, max: 12000 }
        },
        bruxelles: {
          isolation: { min: 1200, max: 7000 },
          chauffage: { min: 600, max: 4500 },
          photovoltaique: { min: 3000, max: 18000 }
        }
      }
    end

    def cache_version
      # Version du cache basée sur la date de déploiement
      Rails.application.config.cache_version_timestamp || Time.current.strftime('%Y%m%d%H%M')
    end
  end
end

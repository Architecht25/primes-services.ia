class RenovateRedirectService
  # Service pour gérer les redirections intelligentes vers Ren0vate

  RENOVATE_BASE_URL = 'https://ren0vate-630b5136c442.herokuapp.com'
  # RENOVATE_BASE_URL = 'https://ren0vate.be' # Alternative URL

  # Mapping des profils vers les pages Ren0vate appropriées
  PROFILE_MAPPINGS = {
    'particulier' => '/particuliers',
    'acp' => '/coproprietes',
    'entreprise_immo' => '/entreprises/immobilier',
    'entreprise_comm' => '/entreprises/commercial',
    'general' => '/'
  }.freeze

  # Mapping des régions
  REGION_MAPPINGS = {
    'wallonie' => 'wallonia',
    'flandre' => 'flanders',
    'bruxelles' => 'brussels',
    'default' => 'wallonia'
  }.freeze

  class << self
    def build_redirect_url(profile:, region: nil, source: 'primes-services-ia', utm_params: {}, additional_params: {})
      # Construit l'URL de redirection complète vers Ren0vate

      base_path = PROFILE_MAPPINGS[profile.to_s] || PROFILE_MAPPINGS['general']
      mapped_region = REGION_MAPPINGS[region.to_s] || REGION_MAPPINGS['default']

      # Paramètres de base
      params = {
        source: source,
        profile: profile,
        region: mapped_region,
        timestamp: Time.current.to_i
      }

      # Ajouter les paramètres UTM
      params.merge!(build_default_utm_params.merge(utm_params))

      # Ajouter les paramètres additionnels
      params.merge!(additional_params) if additional_params.any?

      # Construire l'URL finale
      url = "#{RENOVATE_BASE_URL}#{base_path}"
      url += "?#{params.to_query}" if params.any?

      url
    end

    def redirect_after_contact_submission(contact)
      # Redirection spécialisée après soumission d'un formulaire de contact

      profile = extract_profile_from_contact(contact)
      region = contact.region || 'wallonie'

      # Paramètres spécifiques au contact
      contact_params = {
        contact_id: contact.id,
        contact_type: contact.type,
        urgency: contact.urgency || 'normal',
        budget_range: estimate_budget_range(contact)
      }

      # UTM personnalisés
      utm_params = {
        utm_campaign: "contact_#{profile}",
        utm_content: "form_submission",
        utm_term: contact.work_type || 'general'
      }

      build_redirect_url(
        profile: profile,
        region: region,
        utm_params: utm_params,
        additional_params: contact_params
      )
    end

    def track_redirection(contact, redirect_url)
      # Enregistre la redirection pour suivi et analytics

      tracking_data = {
        contact_id: contact.id,
        redirect_url: redirect_url,
        timestamp: Time.current,
        user_agent: contact.user_agent || 'Unknown',
        referrer: contact.referrer
      }

      # Log pour analytics
      Rails.logger.info "[RENOVATE_REDIRECT] #{tracking_data.to_json}"

      # Mettre à jour le contact avec l'info de redirection
      contact.update(
        redirected_to_renovate: true,
        redirected_at: Time.current,
        renovate_url: redirect_url
      )

      tracking_data
    end

    def get_redirect_analytics(period = 7.days)
      # Récupère les analytics des redirections

      contacts_redirected = ContactSubmission.where(
        redirected_to_renovate: true,
        redirected_at: period.ago..Time.current
      )

      {
        total_redirections: contacts_redirected.count,
        by_profile: contacts_redirected.group(:type).count,
        by_region: contacts_redirected.group(:region).count,
        by_day: contacts_redirected.group_by_day(:redirected_at).count,
        conversion_rate: calculate_conversion_rate(contacts_redirected)
      }
    end

    def test_renovate_connectivity
      # Teste la connectivité avec Ren0vate

      begin
        response = Net::HTTP.get_response(URI(RENOVATE_BASE_URL))
        {
          status: response.code.to_i,
          accessible: response.code.to_i < 400,
          response_time: measure_response_time,
          last_checked: Time.current
        }
      rescue => e
        {
          status: 0,
          accessible: false,
          error: e.message,
          last_checked: Time.current
        }
      end
    end

    private

    def extract_profile_from_contact(contact)
      # Extrait le profil à partir du type de contact STI
      case contact.class.name
      when 'ParticulierContact'
        'particulier'
      when 'AcpContact'
        'acp'
      when 'EntrepriseImmoContact'
        'entreprise_immo'
      when 'EntrepriseCommContact'
        'entreprise_comm'
      else
        'general'
      end
    end

    def estimate_budget_range(contact)
      # Estime la gamme de budget basée sur les données du contact
      return 'unknown' unless contact.respond_to?(:budget)

      budget = contact.budget.to_i
      case budget
      when 0..5000
        'small'
      when 5001..20000
        'medium'
      when 20001..50000
        'large'
      else
        'enterprise'
      end
    end

    def build_default_utm_params
      {
        utm_source: 'primes-services-ia',
        utm_medium: 'website',
        utm_campaign: 'form_redirect'
      }
    end

    def calculate_conversion_rate(contacts)
      # Calcule le taux de conversion (simplifié)
      total_contacts = ContactSubmission.count
      return 0 if total_contacts.zero?

      (contacts.count.to_f / total_contacts * 100).round(2)
    end

    def measure_response_time
      # Mesure le temps de réponse de Ren0vate
      start_time = Time.current
      Net::HTTP.get_response(URI(RENOVATE_BASE_URL))
      ((Time.current - start_time) * 1000).round(2) # en millisecondes
    rescue
      0
    end
  end
end

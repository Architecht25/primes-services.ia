class RedirectionsController < ApplicationController
  # Gère les redirections intelligentes vers Ren0vate après soumission de formulaires

  def to_renovate
    # Redirection principale vers Ren0vate avec paramètres
    profile = params[:profile] || 'general'
    region = params[:region] || detect_user_region
    source = 'primes-services-ia'

    # Construction de l'URL avec paramètres UTM et tracking
    redirect_url = RenovateRedirectService.build_redirect_url(
      profile: profile,
      region: region,
      source: source,
      utm_params: build_utm_params
    )

    # Log de la redirection pour analytics
    log_redirection(redirect_url, profile, region)

    # Redirection avec message flash
    flash[:notice] = "Redirection vers notre plateforme Ren0vate pour finaliser votre demande..."
    redirect_to redirect_url, allow_other_host: true
  end

  def track_click
    # Endpoint pour tracker les clics sans redirection immédiate
    profile = params[:profile]
    region = params[:region]
    element = params[:element] # bouton, lien, etc.

    # Log du tracking
    log_tracking_event('click', element, profile, region)

    render json: { status: 'tracked', timestamp: Time.current }
  end

  def success_callback
    # Callback après succès sur Ren0vate (si implémenté côté Ren0vate)
    contact_id = params[:contact_id]
    status = params[:status]

    if contact_id.present?
      # Mettre à jour le statut du contact
      contact = ContactSubmission.find_by(id: contact_id)
      contact&.update(renovate_status: status, redirected_at: Time.current)
    end

    render json: { status: 'callback_received' }
  end

  private

  def detect_user_region
    # Utilise le service de géolocalisation pour détecter la région
    GeolocationService.detect_region_from_ip(request.remote_ip) || 'wallonie'
  end

  def build_utm_params
    {
      utm_source: 'primes-services-ia',
      utm_medium: 'website',
      utm_campaign: 'contact_form',
      utm_content: params[:profile] || 'general'
    }
  end

  def log_redirection(url, profile, region)
    # Log pour analytics (pourrait être envoyé à Google Analytics, etc.)
    Rails.logger.info "[REDIRECTION] URL: #{url}, Profile: #{profile}, Region: #{region}, IP: #{request.remote_ip}"

    # Ici on pourrait aussi sauvegarder en base pour analytics internes
    # RedirectionLog.create(
    #   url: url,
    #   profile: profile,
    #   region: region,
    #   ip_address: request.remote_ip,
    #   user_agent: request.user_agent
    # )
  end

  def log_tracking_event(event_type, element, profile, region)
    Rails.logger.info "[TRACKING] Event: #{event_type}, Element: #{element}, Profile: #{profile}, Region: #{region}"
  end
end

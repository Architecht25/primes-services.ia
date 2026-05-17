class RedirectionsController < ApplicationController
  # Gère les redirections intelligentes vers Ren0vate après soumission de formulaires

  def to_renovate
    profile = params[:profile] || 'general'
    region  = params[:region]  || detect_user_region
    source  = 'primes-services-ia'

    redirect_url = RenovateRedirectService.build_redirect_url(
      profile: profile,
      region: region,
      source: source,
      utm_params: build_utm_params
    )

    persist_click(event_type: 'redirect', profile: profile, region: region,
                  redirect_url: redirect_url, element: params[:element])

    flash[:notice] = "Redirection vers notre plateforme Ren0vate pour finaliser votre demande..."
    redirect_to redirect_url, allow_other_host: true
  end

  def track_click
    profile = params[:profile]
    region  = params[:region]
    element = params[:element]

    persist_click(event_type: 'click', profile: profile, region: region, element: element)

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

  def persist_click(event_type:, profile:, region:, redirect_url: nil, element: nil)
    RenovateClick.create!(
      event_type:   event_type,
      profile:      profile || 'general',
      region:       region,
      element:      element,
      source_page:  request.referrer,
      redirect_url: redirect_url,
      session_id:   session.id.to_s,
      ip_address:   request.remote_ip,
      user_agent:   request.user_agent,
      referrer:     request.referrer
    )
  rescue => e
    Rails.logger.warn "[RenovateClick] Failed to persist: #{e.message}"
  end
end

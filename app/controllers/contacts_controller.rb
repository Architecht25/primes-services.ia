class ContactsController < ApplicationController
  before_action :set_contact, only: [:show]
  before_action :authorize_contact_view!, only: [:show]

  # Un humain met toujours au moins quelques secondes à remplir le formulaire ;
  # les bots (y compris ceux pilotés par IA) le soumettent quasi instantanément.
  MIN_SUBMISSION_DELAY = 3.seconds

  def new
    @contact = ContactSubmission.new
    # Horodatage serveur, non modifiable par le client, pour détecter les
    # soumissions trop rapides pour être humaines.
    session[:contact_form_rendered_at] = Time.current.to_i
  end

  def create
    # Honeypot: bots fill hidden fields, humans leave them blank
    if params[:website].present?
      Rails.logger.warn "[Security] Honeypot triggered from IP #{request.remote_ip}"
      redirect_to new_contact_path, notice: 'Votre demande a été envoyée avec succès!'
      return
    end

    if submitted_too_fast?
      Rails.logger.warn "[Security] Contact form submitted too fast from IP #{request.remote_ip}"
      redirect_to new_contact_path, notice: 'Votre demande a été envoyée avec succès!'
      return
    end

    unless TurnstileVerificationService.verify(params["cf-turnstile-response"], remote_ip: request.remote_ip)
      Rails.logger.warn "[Security] Turnstile verification failed from IP #{request.remote_ip}"
      @contact = ContactSubmission.new(contact_params)
      @contact.errors.add(:base, "Merci de confirmer que vous n'êtes pas un robot.")
      render :new, status: :unprocessable_entity
      return
    end

    @contact = ContactSubmission.new(contact_params)

    if @contact.save
      # Notifier l'administrateur via Action Mailer / Resend SMTP
      begin
        ContactMailer.new_submission_notification(@contact).deliver_later
      rescue => e
        Rails.logger.error "Erreur envoi notification admin pour contact ##{@contact.id}: #{e.message}"
      end

      # Store submitted contact ID in session so only the submitter can view it
      session[:submitted_contact_id] = @contact.id

      redirect_to contact_path(@contact), notice: 'Votre demande a été envoyée avec succès!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  private

  def submitted_too_fast?
    rendered_at = session[:contact_form_rendered_at]
    return false if rendered_at.blank? # pas de faux positif si la session a expiré

    (Time.current.to_i - rendered_at) < MIN_SUBMISSION_DELAY
  end

  def set_contact
    @contact = ContactSubmission.find(params[:id])
  end

  def authorize_contact_view!
    unless session[:submitted_contact_id] == @contact.id
      redirect_to root_path, alert: "Accès non autorisé."
    end
  end

  def contact_params
    params.require(:contact_submission).permit(:name, :email, :phone, :region, :message, :website)
  end
end

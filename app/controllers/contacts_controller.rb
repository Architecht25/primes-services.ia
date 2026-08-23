class ContactsController < ApplicationController
  before_action :set_contact, only: [:show]
  before_action :authorize_contact_view!, only: [:show]

  def new
    @contact = ContactSubmission.new
  end

  def create
    # Honeypot: bots fill hidden fields, humans leave them blank
    if params[:website].present?
      Rails.logger.warn "[Security] Honeypot triggered from IP #{request.remote_ip}"
      redirect_to new_contact_path, notice: 'Votre demande a été envoyée avec succès!'
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

class ContactsController < ApplicationController
  before_action :set_contact, only: [:show]

  def index
    @contacts = ContactSubmission.recent.limit(10)
  end

  def new
    # Page de sélection du type de contact
  end

  def particulier
    @contact = ParticulierContact.new
    @contact_type = 'particulier'
    render :form
  end

  def acp
    @contact = AcpContact.new
    @contact_type = 'acp'
    render :form
  end

  def entreprise_immo
    @contact = EntrepriseImmoContact.new
    @contact_type = 'entreprise_immo'
    render :form
  end

  def entreprise_comm
    @contact = EntrepriseCommContact.new
    @contact_type = 'entreprise_comm'
    render :form
  end

  def create
    @contact_type = params[:contact_type]

    case @contact_type
    when 'particulier'
      @contact = ParticulierContact.new(particulier_params)
    when 'acp'
      @contact = AcpContact.new(acp_params)
    when 'entreprise_immo'
      @contact = EntrepriseImmoContact.new(entreprise_immo_params)
    when 'entreprise_comm'
      @contact = EntrepriseCommContact.new(entreprise_comm_params)
    else
      redirect_to new_contact_path, alert: 'Type de contact invalide'
      return
    end

    if @contact.save
      # Envoyer l'email de confirmation
      begin
        EmailService.send_contact_confirmation(@contact)
        # Intégrer avec l'IA pour suggestions personnalisées
        ai_suggestions = AiChatbotService.new.generate_personalized_suggestions(@contact)
        @contact.update(ai_suggestions: ai_suggestions)
      rescue => e
        Rails.logger.error "Erreur lors de l'envoi d'email ou génération IA: #{e.message}"
      end

      redirect_to contact_path(@contact), notice: 'Votre demande a été envoyée avec succès!'
    else
      render :form, status: :unprocessable_entity
    end
  end

  def show
    @suggested_subsidies = @contact.suggested_subsidies
    @personalized_message = @contact.generate_personalized_message
  end

  private

  def set_contact
    @contact = ContactSubmission.find(params[:id])
  end

  def particulier_params
    params.require(:particulier_contact).permit(
      :name, :email, :phone, :address, :city, :postal_code, :region,
      :property_type, :construction_year, :surface_area, :work_type,
      :estimated_budget, :timeline, :priority, :current_heating,
      :income_range, :message
    )
  end

  def acp_params
    params.require(:acp_contact).permit(
      :name, :email, :phone, :address, :city, :postal_code, :region,
      :number_of_units, :building_type, :building_work_type, :voted_budget,
      :work_urgency, :syndic_contact, :message
    )
  end

  def entreprise_immo_params
    params.require(:entreprise_immo_contact).permit(
      :name, :email, :phone, :address, :city, :postal_code, :region,
      :business_activity, :investment_region, :project_scale, :timeline,
      :estimated_budget, :target_market, :message
    )
  end

  def entreprise_comm_params
    params.require(:entreprise_comm_contact).permit(
      :name, :email, :phone, :address, :city, :postal_code, :region,
      :business_activity, :investment_region, :project_scale, :timeline,
      :estimated_budget, :target_market, :company_size, :message
    )
  end
end

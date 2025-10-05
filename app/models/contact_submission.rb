class ContactSubmission < ApplicationRecord
  # STI (Single Table Inheritance) configuration
  self.inheritance_column = 'type'

  # Validations communes
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A[\+]?[0-9\s\-\(\)]{10,20}\z/ }, allow_blank: true
  validates :region, presence: true, inclusion: { in: %w[wallonie flandre bruxelles] }
  validates :status, inclusion: { 
    in: %w[pending processed completed archived], 
    message: "%{value} is not a valid status" 
  }

  # Callbacks
  before_validation :set_default_status, on: :create
  before_validation :set_submitted_at, on: :create
  before_validation :normalize_phone
  before_validation :downcase_email

  # Scopes
  scope :by_region, ->(region) { where(region: region) }
  scope :by_status, ->(status) { where(status: status) }
  scope :pending, -> { where(status: 'pending') }
  scope :processed, -> { where(status: 'processed') }
  scope :recent, -> { order(submitted_at: :desc) }
  scope :this_month, -> { where(submitted_at: 1.month.ago..Time.current) }

  # Méthodes d'instance
  def processed?
    status == 'processed'
  end

  def completed?
    status == 'completed'
  end

  def pending?
    status == 'pending'
  end

  def mark_as_processed!
    update!(status: 'processed', processed_at: Time.current)
  end

  def mark_as_completed!
    update!(status: 'completed')
  end

  def processing_time
    return nil unless processed_at && submitted_at
    processed_at - submitted_at
  end

  def contact_summary
    {
      name: name,
      email: email,
      phone: phone,
      region: region,
      type: self.class.name,
      submitted: submitted_at,
      status: status
    }
  end

  # Méthode pour obtenir les champs spécialisés selon le type
  def specialized_fields
    case type
    when 'ParticulierContact'
      {
        property_type: property_type,
        construction_year: construction_year,
        work_type: work_type,
        estimated_budget: estimated_budget,
        realization_deadline: realization_deadline,
        family_situation: family_situation
      }.compact
    when 'AcpContact'
      {
        number_of_units: number_of_units,
        building_type: building_type,
        building_work_type: building_work_type,
        voted_budget: voted_budget,
        syndic_contact: syndic_contact,
        work_urgency: work_urgency
      }.compact
    when 'EntrepriseImmoContact'
      {
        business_activity: business_activity,
        investment_region: investment_region,
        project_type: project_type,
        project_size: project_size,
        investment_budget: investment_budget,
        certifications_targeted: certifications_targeted
      }.compact
    when 'EntrepriseCommContact'
      {
        business_sector: business_sector,
        company_size: company_size,
        activity_region: activity_region,
        investment_type: investment_type,
        business_budget: business_budget,
        business_objectives: business_objectives,
        company_status: company_status
      }.compact
    else
      {}
    end
  end

  # Méthode pour générer un résumé adapté selon le type
  def detailed_summary
    base_summary = {
      id: id,
      type: type,
      contact: contact_summary,
      specialized_data: specialized_fields,
      metadata: metadata || {},
      created_at: created_at,
      updated_at: updated_at
    }

    base_summary
  end

  # Méthode de classe pour les statistiques
  def self.stats_by_region
    group(:region).count
  end

  def self.stats_by_type
    group(:type).count
  end

  def self.stats_by_status
    group(:status).count
  end

  private

  def set_default_status
    self.status ||= 'pending'
  end

  def set_submitted_at
    self.submitted_at ||= Time.current
  end

  def normalize_phone
    return unless phone.present?
    # Supprimer les espaces et caractères non numériques sauf +, -, (, )
    self.phone = phone.gsub(/[^\d\+\-\(\)\s]/, '').strip
  end

  def downcase_email
    self.email = email.downcase.strip if email.present?
  end
end

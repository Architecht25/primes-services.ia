class ContactSubmission < ApplicationRecord
  # STI (Single Table Inheritance) configuration
  self.inheritance_column = 'type'

  # Validations communes
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A[\+]?[0-9\s\-\(\)]{7,15}\z/ }, allow_blank: true
  validates :message, length: { maximum: 2000 }, allow_blank: true
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
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }

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

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
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

  # Résumé complet de la demande (message libre, plus de champs spécialisés par profil)
  def detailed_summary
    {
      id: id,
      contact: contact_summary,
      message: message,
      metadata: metadata || {},
      created_at: created_at,
      updated_at: updated_at
    }
  end

  # Méthode de classe pour les statistiques
  def self.stats_by_region
    group(:region).count
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

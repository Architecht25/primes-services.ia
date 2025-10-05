class AiConversation < ApplicationRecord
  # Validations
  validates :session_id, presence: true, uniqueness: true
  validates :user_type, inclusion: { 
    in: %w[particulier acp entreprise_immo entreprise_comm], 
    allow_nil: true 
  }
  validates :user_region, inclusion: { 
    in: %w[wallonie flandre bruxelles], 
    allow_nil: true 
  }
  validates :status, inclusion: { 
    in: %w[active completed archived], 
    message: "%{value} is not a valid status" 
  }

  # Callbacks
  before_validation :generate_session_id, on: :create
  before_validation :set_default_status, on: :create
  before_save :serialize_messages

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :by_user_type, ->(type) { where(user_type: type) }
  scope :by_region, ->(region) { where(user_region: region) }
  scope :recent, -> { order(created_at: :desc) }

  # Méthodes d'instance
  def messages_array
    JSON.parse(messages || '[]')
  rescue JSON::ParserError
    []
  end

  def messages_array=(value)
    @messages_array = value
  end

  def add_message(role:, content:, metadata: {})
    current_messages = messages_array
    current_messages << {
      role: role,           # 'user' ou 'assistant'
      content: content,
      timestamp: Time.current.iso8601,
      metadata: metadata
    }
    self.messages_array = current_messages
    save
  end

  def last_message
    messages_array.last
  end

  def message_count
    messages_array.length
  end

  def duration_minutes
    return 0 unless created_at && updated_at
    ((updated_at - created_at) / 1.minute).round(2)
  end

  def complete!
    update(status: 'completed')
  end

  def archive!
    update(status: 'archived')
  end

  def user_profile
    {
      type: user_type,
      region: user_region,
      metadata: metadata || {}
    }
  end

  private

  def generate_session_id
    self.session_id ||= SecureRandom.hex(16)
  end

  def set_default_status
    self.status ||= 'active'
  end

  def serialize_messages
    if @messages_array
      self.messages = @messages_array.to_json
    end
  end
end

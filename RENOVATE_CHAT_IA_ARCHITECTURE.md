# Architecture Chat IA pour Ren0vate

## 📋 Vue d'ensemble

Ce document détaille l'architecture complète pour intégrer le système de chat IA avancé dans l'application Ren0vate, basé sur l'implémentation réussie de Primes Services IA.

## 🏗️ Architecture Générale

```
┌─────────────────────────────────────────────────────────────────┐
│                     FRONTEND (Stimulus)                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐ │
│  │   Chat Interface │  │  AI Suggestions  │  │  Response UI     │ │
│  │                  │  │                  │  │                  │ │
│  │ - Message Input  │  │ - Auto Suggest   │  │ - Markdown       │ │
│  │ - Send Button    │  │ - Context Aware  │  │ - Official Links │ │
│  │ - History        │  │ - NLP Based      │  │ - Action Buttons │ │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                     BACKEND (Rails)                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐ │
│  │  AI Controller   │  │   AI Service     │  │   NLP Service    │ │
│  │                  │  │                  │  │                  │ │
│  │ - Chat Endpoint  │  │ - OpenAI API     │  │ - Intent Analysis│ │
│  │ - Suggestions    │  │ - Context Build  │  │ - Entity Extract │ │
│  │ - History        │  │ - Response Proc  │  │ - Confidence     │ │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DATABASE (PostgreSQL)                      │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐ │
│  │ AI Conversations │  │   AI Insights    │  │   Calculations   │ │
│  │                  │  │                  │  │                  │ │
│  │ - Session Data   │  │ - Analytics      │  │ - Results Cache  │ │
│  │ - Messages       │  │ - Patterns       │  │ - Estimations    │ │
│  │ - Context        │  │ - Improvements   │  │ - User Data      │ │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 🗃️ Structure des Fichiers

### 1. Base de Données - Migrations

#### Migration: `create_ai_conversations`
```ruby
# db/migrate/20241006_create_ai_conversations.rb
class CreateAiConversations < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_conversations do |t|
      t.string :session_id, null: false, index: true
      t.string :user_type, index: true
      t.string :user_region, default: 'wallonie', index: true
      t.text :messages, null: true # JSON array
      t.string :status, default: 'active', index: true
      t.text :metadata, null: true # JSON
      t.timestamps
    end
    
    add_index :ai_conversations, [:session_id, :status]
    add_index :ai_conversations, [:user_region, :created_at]
  end
end
```

#### Migration: `create_ai_insights`
```ruby
# db/migrate/20241006_create_ai_insights.rb
class CreateAiInsights < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_insights do |t|
      t.references :ai_conversation, null: false, foreign_key: true
      t.string :insight_type, null: false, index: true
      t.text :data, null: false # JSON
      t.decimal :confidence_score, precision: 5, scale: 4
      t.timestamps
    end
    
    add_index :ai_insights, [:insight_type, :confidence_score]
  end
end
```

#### Migration: `create_calculations`
```ruby
# db/migrate/20241006_create_calculations.rb
class CreateCalculations < ActiveRecord::Migration[7.0]
  def change
    create_table :calculations do |t|
      t.references :ai_conversation, null: true, foreign_key: true
      t.string :calculation_type, null: false, index: true
      t.text :inputs, null: false # JSON
      t.text :results, null: false # JSON
      t.string :status, default: 'completed', index: true
      t.timestamps
    end
    
    add_index :calculations, [:calculation_type, :created_at]
  end
end
```

### 2. Modèles

#### Model: `AiConversation`
```ruby
# app/models/ai_conversation.rb
class AiConversation < ApplicationRecord
  has_many :ai_insights, dependent: :destroy
  has_many :calculations, dependent: :destroy
  
  validates :session_id, presence: true, uniqueness: { scope: :status }
  validates :status, inclusion: { in: %w[active completed archived] }
  validates :user_region, inclusion: { in: %w[wallonie flandre bruxelles] }
  
  enum status: { active: 'active', completed: 'completed', archived: 'archived' }
  enum user_region: { wallonie: 'wallonie', flandre: 'flandre', bruxelles: 'bruxelles' }
  
  # Sérialisation JSON pour les messages
  serialize :messages, Array
  serialize :metadata, Hash
  
  scope :recent, -> { order(updated_at: :desc) }
  scope :by_region, ->(region) { where(user_region: region) }
  
  def messages_array
    messages || []
  end
  
  def add_message(role:, content:, metadata: {})
    current_messages = messages_array
    
    new_message = {
      role: role,
      content: content,
      timestamp: Time.current.iso8601,
      metadata: metadata.merge(
        ip_address: metadata[:ip_address],
        user_agent: metadata[:user_agent],
        referer: metadata[:referer],
        session_id: { public_id: session_id.first(32) },
        timestamp: Time.current.iso8601,
        user_type: user_type,
        user_region: user_region,
        page_url: metadata[:page_url],
        client_timezone: metadata[:client_timezone]
      )
    }
    
    current_messages << new_message
    update!(messages: current_messages)
    new_message
  end
  
  def user_profile
    {
      type: user_type,
      region: user_region,
      metadata: metadata || {}
    }
  end
  
  def conversation_summary
    return {} if messages_array.empty?
    
    user_messages = messages_array.select { |msg| msg['role'] == 'user' }
    assistant_messages = messages_array.select { |msg| msg['role'] == 'assistant' }
    
    {
      total_messages: messages_array.count,
      user_messages_count: user_messages.count,
      assistant_messages_count: assistant_messages.count,
      duration_minutes: duration_in_minutes,
      topics_discussed: extract_topics,
      last_activity: messages_array.last&.dig('timestamp')
    }
  end
  
  private
  
  def duration_in_minutes
    return 0 if messages_array.empty?
    
    first_message_time = Time.parse(messages_array.first['timestamp'])
    last_message_time = Time.parse(messages_array.last['timestamp'])
    ((last_message_time - first_message_time) / 60.0).round(2)
  rescue
    0
  end
  
  def extract_topics
    # Simple topic extraction based on keywords
    all_content = messages_array.map { |msg| msg['content'] }.join(' ').downcase
    
    topics = []
    topics << 'isolation' if all_content.match?(/isolat|thermique|laine/)
    topics << 'chauffage' if all_content.match?(/chauffage|pompe.*chaleur|chaudière/)
    topics << 'renovation' if all_content.match?(/rénovation|travaux|prime/)
    topics << 'audit' if all_content.match?(/audit|énergétique/)
    
    topics.uniq
  end
end
```

#### Model: `AiInsight`
```ruby
# app/models/ai_insight.rb
class AiInsight < ApplicationRecord
  belongs_to :ai_conversation
  
  validates :insight_type, presence: true
  validates :data, presence: true
  validates :confidence_score, presence: true, 
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  
  serialize :data, Hash
  
  scope :high_confidence, -> { where('confidence_score >= ?', 0.8) }
  scope :by_type, ->(type) { where(insight_type: type) }
  
  INSIGHT_TYPES = %w[
    user_intent
    subsidy_match
    property_analysis
    financial_estimate
    next_steps
    user_satisfaction
  ].freeze
  
  validates :insight_type, inclusion: { in: INSIGHT_TYPES }
end
```

#### Model: `Calculation`
```ruby
# app/models/calculation.rb
class Calculation < ApplicationRecord
  belongs_to :ai_conversation, optional: true
  
  validates :calculation_type, presence: true
  validates :inputs, presence: true
  validates :results, presence: true
  
  serialize :inputs, Hash
  serialize :results, Hash
  
  enum status: { pending: 'pending', completed: 'completed', failed: 'failed' }
  
  CALCULATION_TYPES = %w[
    subsidy_estimation
    energy_savings
    roi_analysis
    installation_cost
    payback_period
  ].freeze
  
  validates :calculation_type, inclusion: { in: CALCULATION_TYPES }
  
  scope :successful, -> { where(status: 'completed') }
  scope :by_type, ->(type) { where(calculation_type: type) }
end
```

### 3. Services

#### Service: `AiChatbotService`
```ruby
# app/services/ai_chatbot_service.rb
class AiChatbotService
  include ActionView::Helpers::TextHelper
  
  def initialize(session_id, options = {})
    @session_id = session_id
    @config = load_configuration
    @conversation = find_or_create_conversation(options)
    @nlp_service = NlpService.new(@config)
  end
  
  def process_message(message, user_context = {})
    benchmark "Processing AI message" do
      # 1. Ajouter le message utilisateur
      add_user_message(message, user_context)
      
      # 2. Analyser l'intent avec NLP
      intent_analysis = @nlp_service.analyze_intent(message, conversation_context)
      
      # 3. Construire le contexte spécialisé
      context = build_specialized_context(intent_analysis)
      
      # 4. Appeler OpenAI
      ai_response = call_openai_api(context)
      
      # 5. Enrichir la réponse
      enhanced_response = enhance_response(ai_response, intent_analysis)
      
      # 6. Sauvegarder la réponse
      add_assistant_message(enhanced_response[:content], enhanced_response[:metadata])
      
      enhanced_response
    end
  rescue => e
    handle_error(e, message)
  end
  
  def get_suggestions
    intent_analysis = @nlp_service.analyze_intent(
      recent_context, 
      conversation_context, 
      suggestion_mode: true
    )
    
    build_contextual_suggestions(intent_analysis)
  end
  
  private
  
  def load_configuration
    YAML.load_file(Rails.root.join('config', 'ai.yml'))[Rails.env.to_s].deep_symbolize_keys
  end
  
  def find_or_create_conversation(options = {})
    conversation = AiConversation.find_by(session_id: @session_id, status: 'active')
    
    unless conversation
      conversation = AiConversation.create!(
        session_id: @session_id,
        user_type: options[:user_type],
        user_region: options[:user_region] || 'wallonie',
        status: 'active',
        metadata: options[:metadata] || {}
      )
    end
    
    conversation
  end
  
  def build_specialized_context(intent_analysis)
    {
      system_prompt: build_system_prompt,
      user_profile: @conversation.user_profile,
      intent: intent_analysis,
      conversation_history: recent_conversation_history,
      regional_info: get_regional_context,
      subsidy_database: get_relevant_subsidies(intent_analysis),
      calculation_context: get_calculation_context(intent_analysis)
    }
  end
  
  def build_system_prompt
    assistant_name = @config.dig(:assistant, :name)
    user_region = @conversation.user_region || @config.dig(:regions, :default)
    user_type = @conversation.user_type || "visiteur"
    regional_info = get_regional_context
    
    <<~PROMPT
      Tu es #{assistant_name}, l'assistant IA spécialisé en rénovation énergétique et subsides en Belgique pour Ren0vate.

      CONTEXTE UTILISATEUR:
      - Profil: #{user_type}
      - Région: #{user_region}
      - Langue: #{@config.dig(:assistant, :language)}
      - Plateforme: Ren0vate (accompagnement complet en rénovation)

      TON RÔLE:
      - Expert en rénovation énergétique et subsides belges
      - Calculateur de primes et estimations financières
      - Guide personnalisé selon le profil, la région et le type de projet
      - Assistant Ren0vate pour l'accompagnement complet

      SOURCES OFFICIELLES (#{regional_info[:name]}):
      #{regional_info[:official_urls]&.map { |type, url| "- #{type.to_s.humanize}: #{url}" }&.join("\n") || "Sources non disponibles"}
      
      IMPORTANT: #{regional_info[:key_info]}

      CAPACITÉS SPÉCIALES REN0VATE:
      - Calcul précis des primes par région
      - Estimation des coûts de rénovation
      - Analyse ROI et temps de retour
      - Recommandations d'entrepreneurs agréés
      - Suivi de projet personnalisé

      RÈGLES IMPORTANTES:
      1. Réponds toujours en français belge (#{@config.dig(:assistant, :language)})
      2. Sois précis sur les montants et conditions selon la région
      3. TOUJOURS mentionner les sources officielles
      4. Propose des calculs concrets avec Ren0vate
      5. Redirige vers les services Ren0vate pour l'accompagnement
      6. Inclus les liens officiels quand pertinent
      7. Propose des actions concrètes et chiffrées

      STYLE:
      - Expert mais accessible
      - Utilise des exemples concrets avec chiffres
      - Structure tes réponses clairement
      - Propose des boutons d'action Ren0vate
      - Mentionne les sources officielles pour la crédibilité
      - Focus sur l'accompagnement personnalisé

      Tu as accès aux données temps réel des subsides et aux outils de calcul Ren0vate.
    PROMPT
  end
  
  def get_regional_context
    region = @conversation.user_region || @config.dig(:regions, :default)
    
    case region
    when 'wallonie'
      {
        name: 'Wallonie',
        authority: 'Région wallonne',
        language: 'fr',
        specific_programs: ['Prime Habitation', 'Audits énergétiques', 'Prime isolation', 'Prime chauffage'],
        contact_info: 'Service Public de Wallonie',
        official_urls: {
          main: 'https://energie.wallonie.be/',
          prime_habitation: 'https://energie.wallonie.be/fr/prime-habitation.html',
          audit_energetique: 'https://energie.wallonie.be/fr/audit-energetique-et-architectural.html',
          isolation: 'https://energie.wallonie.be/fr/prime-isolation.html',
          chauffage: 'https://energie.wallonie.be/fr/prime-chauffage.html',
          renovation: 'https://energie.wallonie.be/fr/prime-renovation.html'
        },
        key_info: 'Référez-vous toujours aux informations officielles du Service Public de Wallonie pour les montants et conditions exactes.'
      }
    when 'flandre'
      {
        name: 'Flandre',
        authority: 'Vlaams Gewest',
        language: 'nl',
        specific_programs: ['Vlaamse renovatiepremie', 'Energiepremie'],
        contact_info: 'Vlaams Energie- en Klimaatagentschap',
        official_urls: {
          main: 'https://www.vlaanderen.be/',
          renovation: 'https://www.vlaanderen.be/premies-voor-verbouwingen',
          energie: 'https://www.vlaanderen.be/bouwen-wonen-en-energie',
          isolation: 'https://www.vlaanderen.be/premie-voor-isolatie',
          chauffage: 'https://www.vlaanderen.be/premie-voor-verwarmingsinstallatie'
        },
        key_info: 'Verwijs altijd naar de officiële informatie van de Vlaamse overheid voor exacte bedragen en voorwaarden.'
      }
    when 'bruxelles'
      {
        name: 'Bruxelles-Capitale',
        authority: 'Région de Bruxelles-Capitale',
        language: 'fr/nl',
        specific_programs: ['Prime Renolution', 'Prime énergie'],
        contact_info: 'Bruxelles Environnement',
        official_urls: {
          main: 'https://www.bruxellesenvironnement.be/',
          primes: 'https://www.bruxellesenvironnement.be/particuliers/mes-aides-financieres-et-primes',
          renolution: 'https://www.renolution.brussels/',
          isolation: 'https://www.bruxellesenvironnement.be/particuliers/mes-aides-financieres-et-primes/prime-energie/isolation',
          chauffage: 'https://www.bruxellesenvironnement.be/particuliers/mes-aides-financieres-et-primes/prime-energie/chauffage'
        },
        key_info: 'Référez-vous toujours aux informations officielles de Bruxelles Environnement pour les montants et conditions exactes.'
      }
    else
      {
        name: 'Belgique',
        authority: 'National',
        language: 'fr/nl',
        specific_programs: [],
        contact_info: 'Service fédéral',
        official_urls: {},
        key_info: 'Veuillez spécifier votre région pour obtenir des informations précises sur les primes disponibles.'
      }
    end
  end
  
  def enhance_response(ai_content, intent_analysis)
    # Enrichir la réponse avec des actions suggérées et les liens officiels
    actions = build_suggested_actions(intent_analysis)
    enhanced_content = add_official_links(ai_content, intent_analysis)
    calculations = trigger_calculations(intent_analysis)
    
    {
      content: enhanced_content,
      actions: actions,
      calculations: calculations,
      metadata: {
        intent: intent_analysis,
        response_type: determine_response_type(enhanced_content),
        timestamp: Time.current.iso8601,
        model_used: @config.dig(:openai, :model)
      }
    }
  end
  
  def add_official_links(content, intent_analysis)
    regional_info = get_regional_context
    return content unless regional_info[:official_urls]&.any?
    
    # Ajouter les liens pertinents selon l'intent
    relevant_links = []
    
    case intent_analysis[:category]
    when :isolation
      relevant_links << { text: "Prime isolation", url: regional_info[:official_urls][:isolation] } if regional_info[:official_urls][:isolation]
    when :chauffage
      relevant_links << { text: "Prime chauffage", url: regional_info[:official_urls][:chauffage] } if regional_info[:official_urls][:chauffage]
    when :renovation_generale, :aide_financiere
      relevant_links << { text: "Prime rénovation", url: regional_info[:official_urls][:renovation] } if regional_info[:official_urls][:renovation]
      relevant_links << { text: "Prime habitation", url: regional_info[:official_urls][:prime_habitation] } if regional_info[:official_urls][:prime_habitation]
    when :audit_energetique
      relevant_links << { text: "Audit énergétique", url: regional_info[:official_urls][:audit_energetique] } if regional_info[:official_urls][:audit_energetique]
    end
    
    # Toujours ajouter le lien principal
    relevant_links << { text: "Site officiel #{regional_info[:name]}", url: regional_info[:official_urls][:main] } if regional_info[:official_urls][:main]
    
    if relevant_links.any?
      links_section = "\n\n**📋 Sources officielles :**\n"
      relevant_links.each do |link|
        links_section += "- [#{link[:text]}](#{link[:url]})\n"
      end
      
      # Ajouter section Ren0vate
      links_section += "\n**🏠 Accompagnement Ren0vate :**\n"
      links_section += "- [Calculateur de primes personnalisé](#{renovate_calculator_url})\n"
      links_section += "- [Demande d'accompagnement gratuit](#{renovate_contact_url})\n"
      
      content + links_section
    else
      content
    end
  end
  
  def trigger_calculations(intent_analysis)
    calculations = []
    
    case intent_analysis[:category]
    when :isolation, :chauffage, :renovation_generale
      # Déclencher des calculs automatiques
      if intent_analysis[:entities][:amounts]&.any? || intent_analysis[:entities][:property_types]&.any?
        calculation = CalculationService.new(@conversation).perform(
          type: intent_analysis[:category],
          inputs: {
            region: @conversation.user_region,
            entities: intent_analysis[:entities],
            context: intent_analysis[:user_context]
          }
        )
        calculations << calculation if calculation
      end
    end
    
    calculations
  end
  
  def build_suggested_actions(intent_analysis)
    actions = []
    
    case intent_analysis[:category]
    when :isolation, :chauffage, :renovation_generale
      actions << {
        type: 'calculation',
        label: 'Calculer mes primes exactes',
        url: renovate_calculator_url(intent_analysis[:category]),
        primary: true,
        icon: '🧮'
      }
      actions << {
        type: 'contact',
        label: 'Demander un accompagnement',
        url: renovate_contact_url,
        icon: '👥'
      }
    when :audit_energetique
      actions << {
        type: 'audit',
        label: 'Demander un audit énergétique',
        url: renovate_audit_url,
        primary: true,
        icon: '🔍'
      }
    end
    
    # Action universelle
    actions << {
      type: 'info',
      label: 'Explorer toutes les primes disponibles',
      url: renovate_subsidy_explorer_url,
      icon: '📊'
    }
    
    actions
  end
  
  def call_openai_api(context)
    messages = build_openai_messages(context)
    
    response = @config.dig(:openai, :client).chat(
      parameters: {
        model: @config.dig(:openai, :model),
        messages: messages,
        max_tokens: @config.dig(:openai, :max_tokens),
        temperature: @config.dig(:openai, :temperature),
        stream: false
      }
    )
    
    content = response.dig('choices', 0, 'message', 'content')
    
    log_debug "OpenAI Response", {
      model: @config.dig(:openai, :model),
      tokens_used: response.dig('usage', 'total_tokens'),
      content_preview: content&.truncate(100)
    } if @config.dig(:debug, :enabled)
    
    content
  rescue => e
    log_error "OpenAI API Error", e
    "Je suis désolé, je rencontre une difficulté technique. Pouvez-vous reformuler votre question ?"
  end
  
  # Helpers pour les URLs Ren0vate
  def renovate_calculator_url(category = nil)
    base_url = "https://www.renovate.be/calculateur"
    category ? "#{base_url}?type=#{category}" : base_url
  end
  
  def renovate_contact_url
    "https://www.renovate.be/contact"
  end
  
  def renovate_audit_url
    "https://www.renovate.be/audit-energetique"
  end
  
  def renovate_subsidy_explorer_url
    "https://www.renovate.be/primes-subsides"
  end
  
  # ... autres méthodes privées (voir implementation complète)
end
```

### 4. Configuration

#### Configuration: `config/ai.yml`
```yaml
# config/ai.yml
development: &default
  assistant:
    name: "Assistant Ren0vate"
    language: "fr-BE"
    personality: "expert_renovation"
    
  openai:
    api_key: <%= ENV['OPENAI_API_KEY'] %>
    model: "gpt-4o-mini"
    max_tokens: 1500
    temperature: 0.3
    timeout: 30
    
  regions:
    default: "wallonie"
    supported: ["wallonie", "flandre", "bruxelles"]
    
  nlp:
    confidence_threshold: 0.6
    entity_recognition: true
    intent_categories:
      - isolation
      - chauffage
      - renovation_generale
      - audit_energetique
      - aide_financiere
      - procedure
      - information_generale
      
  cache:
    ttl: 3600
    enabled: true
    
  debug:
    enabled: true
    log_level: "info"

test:
  <<: *default
  openai:
    api_key: "test_key"
    model: "gpt-3.5-turbo"
    
production:
  <<: *default
  debug:
    enabled: false
    log_level: "error"
```

### 5. Frontend (Stimulus)

#### Controller: `ai_chat_controller.js`
```javascript
// app/javascript/controllers/ai_chat_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", 
    "messages", 
    "sendButton", 
    "suggestions", 
    "typing",
    "calculationResults"
  ]
  
  static values = {
    conversationId: String,
    userType: String,
    userRegion: String,
    endpoint: String
  }
  
  connect() {
    this.conversationId = this.conversationIdValue || this.generateConversationId()
    this.loadSuggestions()
    this.setupEventListeners()
  }
  
  async sendMessage(event) {
    event.preventDefault()
    
    const message = this.inputTarget.value.trim()
    if (!message) return
    
    this.disableInput()
    this.addUserMessage(message)
    this.showTypingIndicator()
    
    try {
      const response = await this.postMessage(message)
      this.hideTypingIndicator()
      this.addAssistantMessage(response)
      this.updateCalculations(response.calculations)
      this.updateSuggestions()
    } catch (error) {
      this.hideTypingIndicator()
      this.showError("Erreur de connexion. Veuillez réessayer.")
    } finally {
      this.enableInput()
      this.clearInput()
    }
  }
  
  async postMessage(message) {
    const response = await fetch(this.endpointValue || '/ai/send_message', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        message: message,
        conversation_id: this.conversationId,
        userType: this.userTypeValue,
        userRegion: this.userRegionValue,
        timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
        pageUrl: window.location.href
      })
    })
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }
    
    return response.json()
  }
  
  addUserMessage(message) {
    const messageElement = this.createMessageElement('user', message)
    this.messagesTarget.appendChild(messageElement)
    this.scrollToBottom()
  }
  
  addAssistantMessage(response) {
    const messageElement = this.createMessageElement('assistant', response.content)
    
    // Ajouter les actions si disponibles
    if (response.actions && response.actions.length > 0) {
      const actionsElement = this.createActionsElement(response.actions)
      messageElement.appendChild(actionsElement)
    }
    
    this.messagesTarget.appendChild(messageElement)
    this.scrollToBottom()
  }
  
  createMessageElement(role, content) {
    const messageDiv = document.createElement('div')
    messageDiv.className = `message message--${role} p-4 mb-4 rounded-lg`
    messageDiv.className += role === 'user' 
      ? ' bg-blue-500 text-white ml-8' 
      : ' bg-gray-100 text-gray-800 mr-8'
    
    // Traiter le markdown
    const contentDiv = document.createElement('div')
    contentDiv.className = 'message-content prose max-w-none'
    contentDiv.innerHTML = this.processMarkdown(content)
    
    messageDiv.appendChild(contentDiv)
    return messageDiv
  }
  
  createActionsElement(actions) {
    const actionsDiv = document.createElement('div')
    actionsDiv.className = 'mt-4 flex flex-wrap gap-2'
    
    actions.forEach(action => {
      const button = document.createElement('a')
      button.href = action.url
      button.className = `inline-flex items-center px-3 py-2 text-sm rounded-md transition-colors ${
        action.primary 
          ? 'bg-blue-600 text-white hover:bg-blue-700' 
          : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
      }`
      button.target = action.type === 'external' ? '_blank' : '_self'
      
      if (action.icon) {
        button.innerHTML = `${action.icon} ${action.label}`
      } else {
        button.textContent = action.label
      }
      
      actionsDiv.appendChild(button)
    })
    
    return actionsDiv
  }
  
  updateCalculations(calculations) {
    if (!calculations || calculations.length === 0) return
    if (!this.hasCalculationResultsTarget) return
    
    const resultsDiv = this.calculationResultsTarget
    resultsDiv.innerHTML = ''
    
    calculations.forEach(calc => {
      const calcElement = this.createCalculationElement(calc)
      resultsDiv.appendChild(calcElement)
    })
    
    resultsDiv.classList.remove('hidden')
  }
  
  createCalculationElement(calculation) {
    const calcDiv = document.createElement('div')
    calcDiv.className = 'bg-green-50 border border-green-200 rounded-lg p-4 mb-4'
    
    calcDiv.innerHTML = `
      <h3 class="text-lg font-semibold text-green-800 mb-2">
        🧮 ${this.getCalculationTitle(calculation.calculation_type)}
      </h3>
      <div class="space-y-2">
        ${this.renderCalculationResults(calculation.results)}
      </div>
    `
    
    return calcDiv
  }
  
  getCalculationTitle(type) {
    const titles = {
      'subsidy_estimation': 'Estimation des Primes',
      'energy_savings': 'Économies d\'Énergie',
      'roi_analysis': 'Retour sur Investissement',
      'installation_cost': 'Coût d\'Installation'
    }
    return titles[type] || 'Calcul'
  }
  
  renderCalculationResults(results) {
    return Object.entries(results).map(([key, value]) => {
      if (typeof value === 'number' && key.includes('amount')) {
        return `<div class="flex justify-between">
          <span class="text-gray-600">${this.humanizeKey(key)}:</span>
          <span class="font-semibold text-green-700">${value.toLocaleString('fr-BE')} €</span>
        </div>`
      } else {
        return `<div class="flex justify-between">
          <span class="text-gray-600">${this.humanizeKey(key)}:</span>
          <span class="text-gray-800">${value}</span>
        </div>`
      }
    }).join('')
  }
  
  async loadSuggestions() {
    try {
      const response = await fetch('/ai/suggestions', {
        method: 'GET',
        headers: {
          'X-Conversation-ID': this.conversationId,
          'X-User-Region': this.userRegionValue
        }
      })
      
      if (response.ok) {
        const suggestions = await response.json()
        this.displaySuggestions(suggestions)
      }
    } catch (error) {
      console.log('Suggestions non disponibles')
    }
  }
  
  displaySuggestions(suggestions) {
    if (!this.hasSuggestionsTarget || !suggestions.length) return
    
    this.suggestionsTarget.innerHTML = suggestions.map(suggestion => 
      `<button 
        class="suggestion-button px-3 py-2 text-sm bg-blue-100 hover:bg-blue-200 text-blue-800 rounded-full transition-colors" 
        data-action="click->ai-chat#useSuggestion"
        data-suggestion="${suggestion}">
        ${suggestion}
      </button>`
    ).join('')
  }
  
  useSuggestion(event) {
    const suggestion = event.target.dataset.suggestion
    this.inputTarget.value = suggestion
    this.inputTarget.focus()
  }
  
  processMarkdown(content) {
    // Simple markdown processing
    return content
      .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
      .replace(/\*(.*?)\*/g, '<em>$1</em>')
      .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank" class="text-blue-600 hover:underline">$1</a>')
      .replace(/\n/g, '<br>')
  }
  
  // Utility methods
  generateConversationId() {
    return 'conv_' + Math.random().toString(36).substr(2, 9) + Date.now().toString(36)
  }
  
  humanizeKey(key) {
    return key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())
  }
  
  showTypingIndicator() {
    if (this.hasTypingTarget) {
      this.typingTarget.classList.remove('hidden')
    }
  }
  
  hideTypingIndicator() {
    if (this.hasTypingTarget) {
      this.typingTarget.classList.add('hidden')
    }
  }
  
  disableInput() {
    this.inputTarget.disabled = true
    this.sendButtonTarget.disabled = true
  }
  
  enableInput() {
    this.inputTarget.disabled = false
    this.sendButtonTarget.disabled = false
    this.inputTarget.focus()
  }
  
  clearInput() {
    this.inputTarget.value = ''
  }
  
  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
  
  showError(message) {
    const errorElement = this.createMessageElement('assistant', `❌ ${message}`)
    errorElement.classList.add('message--error', 'bg-red-100', 'text-red-800')
    this.messagesTarget.appendChild(errorElement)
    this.scrollToBottom()
  }
  
  setupEventListeners() {
    // Enter pour envoyer
    this.inputTarget.addEventListener('keypress', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault()
        this.sendMessage(e)
      }
    })
    
    // Auto-resize textarea
    this.inputTarget.addEventListener('input', () => {
      this.inputTarget.style.height = 'auto'
      this.inputTarget.style.height = this.inputTarget.scrollHeight + 'px'
    })
  }
}
```

### 6. Vues (ERB)

#### Vue: `chat.html.erb`
```erb
<%# app/views/ai/chat.html.erb %>
<div class="max-w-4xl mx-auto p-6" 
     data-controller="ai-chat"
     data-ai-chat-conversation-id-value="<%= params[:conversation_id] || SecureRandom.uuid %>"
     data-ai-chat-user-type-value="<%= current_user&.user_type || 'visiteur' %>"
     data-ai-chat-user-region-value="<%= session[:user_region] || 'wallonie' %>"
     data-ai-chat-endpoint-value="/ai/send_message">
  
  <!-- Header -->
  <div class="bg-gradient-to-r from-green-600 to-blue-600 text-white rounded-t-lg p-6">
    <div class="flex items-center space-x-4">
      <div class="w-12 h-12 bg-white rounded-full flex items-center justify-center">
        🏠
      </div>
      <div>
        <h1 class="text-2xl font-bold">Assistant Ren0vate</h1>
        <p class="text-green-100">Votre expert en rénovation énergétique et primes</p>
      </div>
    </div>
  </div>
  
  <!-- Chat Container -->
  <div class="bg-white border-x border-gray-200 min-h-96">
    <!-- Messages Area -->
    <div class="h-96 overflow-y-auto p-4 space-y-4" 
         data-ai-chat-target="messages">
      
      <!-- Message de bienvenue -->
      <div class="message message--assistant bg-gray-100 text-gray-800 p-4 rounded-lg mr-8">
        <div class="message-content prose max-w-none">
          <p>👋 Bonjour ! Je suis l'Assistant Ren0vate, votre expert en rénovation énergétique.</p>
          <p>Je peux vous aider à :</p>
          <ul>
            <li>🧮 <strong>Calculer vos primes</strong> selon votre région</li>
            <li>💡 <strong>Estimer vos économies</strong> d'énergie</li>
            <li>📊 <strong>Analyser votre ROI</strong> et temps de retour</li>
            <li>🔍 <strong>Recommander des solutions</strong> adaptées</li>
            <li>👥 <strong>Vous accompagner</strong> dans votre projet</li>
          </ul>
          <p>Comment puis-je vous accompagner dans votre projet de rénovation ?</p>
        </div>
      </div>
    </div>
    
    <!-- Typing Indicator -->
    <div class="px-4 pb-2 hidden" data-ai-chat-target="typing">
      <div class="flex items-center space-x-2 text-gray-500">
        <div class="flex space-x-1">
          <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
          <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0.1s"></div>
          <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
        </div>
        <span class="text-sm">Assistant Ren0vate tape...</span>
      </div>
    </div>
  </div>
  
  <!-- Suggestions -->
  <div class="bg-gray-50 border-x border-gray-200 p-4">
    <div class="flex flex-wrap gap-2" data-ai-chat-target="suggestions">
      <!-- Les suggestions seront chargées dynamiquement -->
    </div>
  </div>
  
  <!-- Calculation Results -->
  <div class="hidden bg-blue-50 border-x border-gray-200 p-4" 
       data-ai-chat-target="calculationResults">
    <!-- Les résultats de calculs apparaîtront ici -->
  </div>
  
  <!-- Input Area -->
  <div class="bg-white border border-gray-200 rounded-b-lg p-4">
    <form data-action="submit->ai-chat#sendMessage" class="flex space-x-4">
      <textarea 
        data-ai-chat-target="input"
        placeholder="Posez votre question sur la rénovation, les primes, l'isolation..."
        class="flex-1 resize-none border border-gray-300 rounded-lg px-4 py-3 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        rows="1"></textarea>
      
      <button 
        type="submit"
        data-ai-chat-target="sendButton"
        class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-medium transition-colors flex items-center space-x-2">
        <span>Envoyer</span>
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"></path>
        </svg>
      </button>
    </form>
    
    <div class="mt-2 text-xs text-gray-500 text-center">
      Appuyez sur Entrée pour envoyer, Shift+Entrée pour une nouvelle ligne
    </div>
  </div>
  
  <!-- Features Badge -->
  <div class="mt-4 text-center">
    <div class="inline-flex items-center space-x-4 text-sm text-gray-600">
      <span class="flex items-center space-x-1">
        <span class="w-2 h-2 bg-green-500 rounded-full"></span>
        <span>IA Expert</span>
      </span>
      <span class="flex items-center space-x-1">
        <span class="w-2 h-2 bg-blue-500 rounded-full"></span>
        <span>Calculs Précis</span>
      </span>
      <span class="flex items-center space-x-1">
        <span class="w-2 h-2 bg-purple-500 rounded-full"></span>
        <span>Sources Officielles</span>
      </span>
    </div>
  </div>
</div>

<!-- Styles CSS additionnels -->
<style>
  .message-content a {
    @apply text-blue-600 hover:underline;
  }
  
  .message-content ul {
    @apply list-disc list-inside space-y-1;
  }
  
  .message-content strong {
    @apply font-semibold;
  }
  
  .suggestion-button:hover {
    transform: translateY(-1px);
  }
  
  .animate-bounce {
    animation: bounce 1.4s infinite;
  }
  
  @keyframes bounce {
    0%, 80%, 100% {
      transform: translateY(0);
    }
    40% {
      transform: translateY(-6px);
    }
  }
</style>
```

### 7. Routes

#### Routes: `routes.rb`
```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Routes AI Chat
  namespace :ai do
    get 'chat', to: 'ai#chat'
    post 'send_message', to: 'ai#send_message'
    get 'suggestions', to: 'ai#suggestions'
    get 'conversation/:id', to: 'ai#conversation'
    delete 'conversation/:id', to: 'ai#destroy_conversation'
  end
  
  # Routes API pour l'intégration
  namespace :api do
    namespace :v1 do
      namespace :ai do
        resources :conversations, only: [:create, :show, :update]
        post 'chat', to: 'chat#process'
        get 'analytics', to: 'analytics#index'
      end
    end
  end
end
```

### 8. Contrôleur

#### Contrôleur: `AiController`
```ruby
# app/controllers/ai_controller.rb
class AiController < ApplicationController
  before_action :set_conversation_id
  before_action :set_user_context
  
  def chat
    @conversation = find_or_create_conversation
    @suggestions = AiChatbotService.new(@conversation_id, @user_context).get_suggestions
  end
  
  def send_message
    message = params[:message]
    
    if message.blank?
      render json: { error: 'Message requis' }, status: :bad_request
      return
    end
    
    begin
      service = AiChatbotService.new(@conversation_id, @user_context)
      response = service.process_message(message, request_metadata)
      
      render json: response
    rescue => e
      Rails.logger.error "AI Service Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      render json: { 
        error: 'Erreur du service IA',
        content: "Je suis désolé, une erreur technique s'est produite. Pouvez-vous reformuler votre question ?",
        metadata: { error_type: e.class.name }
      }, status: :unprocessable_entity
    end
  end
  
  def suggestions
    service = AiChatbotService.new(@conversation_id, @user_context)
    suggestions = service.get_suggestions
    
    render json: suggestions
  end
  
  def conversation
    conversation = AiConversation.find_by(session_id: params[:id])
    
    if conversation
      render json: {
        conversation: conversation,
        summary: conversation.conversation_summary,
        insights: conversation.ai_insights.recent.limit(10)
      }
    else
      render json: { error: 'Conversation non trouvée' }, status: :not_found
    end
  end
  
  def destroy_conversation
    conversation = AiConversation.find_by(session_id: params[:id])
    
    if conversation
      conversation.update!(status: 'archived')
      render json: { message: 'Conversation archivée' }
    else
      render json: { error: 'Conversation non trouvée' }, status: :not_found
    end
  end
  
  private
  
  def set_conversation_id
    @conversation_id = params[:conversation_id] || 
                     request.headers['X-Conversation-ID'] || 
                     session[:ai_conversation_id] ||
                     SecureRandom.uuid
    
    session[:ai_conversation_id] = @conversation_id
  end
  
  def set_user_context
    @user_context = {
      user_type: current_user&.user_type || params[:userType] || 'visiteur',
      user_region: session[:user_region] || params[:userRegion] || request.headers['X-User-Region'] || 'wallonie',
      user_id: current_user&.id,
      session_id: session.id,
      metadata: {
        locale: I18n.locale,
        platform: 'renovate',
        version: Rails.application.version
      }
    }
  end
  
  def find_or_create_conversation
    AiConversation.find_or_create_by(
      session_id: @conversation_id,
      status: 'active'
    ) do |conversation|
      conversation.user_type = @user_context[:user_type]
      conversation.user_region = @user_context[:user_region]
      conversation.metadata = @user_context[:metadata]
    end
  end
  
  def request_metadata
    {
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      referer: request.referer,
      page_url: params[:pageUrl],
      client_timezone: params[:timezone],
      device_type: detect_device_type,
      browser_info: extract_browser_info
    }
  end
  
  def detect_device_type
    agent = request.user_agent.to_s.downcase
    return 'mobile' if agent.match?(/mobile|android|iphone|ipad/)
    return 'tablet' if agent.match?(/tablet|ipad/)
    'desktop'
  end
  
  def extract_browser_info
    agent = request.user_agent.to_s
    {
      full_agent: agent,
      is_bot: agent.match?(/bot|crawl|spider/i),
      supports_webp: request.headers['Accept']&.include?('image/webp')
    }
  end
end
```

## 🚀 Instructions de Déploiement

### Étapes d'implémentation :

1. **Migration de base de données :**
   ```bash
   rails generate migration CreateAiConversations
   rails generate migration CreateAiInsights  
   rails generate migration CreateCalculations
   rails db:migrate
   ```

2. **Configuration OpenAI :**
   ```bash
   # Ajouter à .env
   OPENAI_API_KEY=your_openai_api_key_here
   ```

3. **Installation des services :**
   - Copier tous les services dans `app/services/`
   - Ajouter le contrôleur AI
   - Intégrer les vues et contrôleurs Stimulus

4. **Configuration des routes :**
   - Ajouter les routes AI au `routes.rb`

5. **Tests et validation :**
   ```bash
   rails console
   service = AiChatbotService.new("test_session")
   service.process_message("Bonjour, je veux isoler ma maison")
   ```

Cette architecture garantit une intégration complète du système de chat IA dans Ren0vate avec toutes les fonctionnalités avancées testées dans Primes Services IA.
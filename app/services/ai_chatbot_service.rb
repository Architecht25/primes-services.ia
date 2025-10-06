# Service principal pour le chatbot IA de primes-services.ia
# Gère l'intégration OpenAI et la logique métier spécialisée en subsides belges
class AiChatbotService
  include ActiveSupport::Benchmarkable

  attr_reader :conversation, :config

  def initialize(session_id: nil, user_type: nil, user_region: nil)
    @config = Rails.application.config.ai
    @conversation = find_or_create_conversation(session_id, user_type, user_region)
    @openai_client = build_openai_client
    @logger = Rails.logger
  end

  # Méthode logger pour le module Benchmarkable
  def logger
    @logger
  end

  # Point d'entrée principal pour traiter un message utilisateur
  def process_message(user_message, metadata: {})
    return error_response("Message vide") if user_message.blank?

    benchmark "Processing AI message" do
      begin
        # 1. Ajouter le message utilisateur à la conversation
        @conversation.add_message(
          role: 'user',
          content: user_message,
          metadata: metadata
        )

        # 2. Analyser l'intent et le contexte
        intent_analysis = analyze_user_intent(user_message)

        # 3. Préparer le contexte spécialisé
        specialized_context = build_specialized_context(intent_analysis)

        # 4. Générer la réponse IA
        ai_response = generate_ai_response(user_message, specialized_context)

        # 5. Post-traitement et enrichissement
        enhanced_response = enhance_response(ai_response, intent_analysis)

        # 6. Sauvegarder la réponse
        @conversation.add_message(
          role: 'assistant',
          content: enhanced_response[:content],
          metadata: enhanced_response[:metadata]
        )

        success_response(enhanced_response)

      rescue => e
        handle_error(e, user_message)
      end
    end
  end

  # Récupère l'historique de conversation
  def conversation_history
    @conversation.messages_array
  end

  # Réinitialise la conversation
  def reset_conversation!
    @conversation.update(messages: '[]', status: 'active')
  end

  # Marque la conversation comme terminée
  def complete_conversation!
    @conversation.complete!
  end

  # Statistiques de conversation
  def conversation_stats
    {
      message_count: @conversation.message_count,
      duration_minutes: @conversation.duration_minutes,
      user_profile: @conversation.user_profile,
      session_id: @conversation.session_id
    }
  end

  private

  def find_or_create_conversation(session_id, user_type, user_region)
    if session_id.present?
      conversation = AiConversation.find_by(session_id: session_id)
      return conversation if conversation
    end

    AiConversation.create!(
      user_type: user_type,
      user_region: user_region || @config.dig(:regions, :default)
    )
  end

  def build_openai_client
    OpenAI::Client.new(
      access_token: @config.dig(:openai, :api_key),
      log_errors: @config.dig(:debug, :enabled)
    )
  end

  def analyze_user_intent(message)
    # Déléguer à NaturalLanguageProcessor pour une analyse plus poussée
    NaturalLanguageProcessor.new.analyze(message, @conversation.user_profile)
  end

  def build_specialized_context(intent_analysis)
    context = {
      system_prompt: build_system_prompt,
      user_profile: @conversation.user_profile,
      intent: intent_analysis,
      conversation_history: recent_conversation_history,
      regional_info: get_regional_context,
      subsidy_database: get_relevant_subsidies(intent_analysis)
    }

    log_debug "Built specialized context", context if @config.dig(:debug, :enabled)
    context
  end

  def build_system_prompt
    assistant_name = @config.dig(:assistant, :name)
    user_region = @conversation.user_region || @config.dig(:regions, :default)
    user_type = @conversation.user_type || "visiteur"

    <<~PROMPT
      Tu es #{assistant_name}, l'assistant IA spécialisé en subsides et primes en Belgique.

      CONTEXTE UTILISATEUR:
      - Profil: #{user_type}
      - Région: #{user_region}
      - Langue: #{@config.dig(:assistant, :language)}

      TON RÔLE:
      - Expert en subsides belges (324 subsides dans ta base de données)
      - Conseiller personnalisé selon le profil et la région
      - Guide vers les bonnes démarches et Ren0vate pour l'accompagnement complet

      RÈGLES IMPORTANTES:
      1. Réponds toujours en français belge (#{@config.dig(:assistant, :language)})
      2. Sois précis sur les montants et conditions selon la région
      3. Propose toujours des actions concrètes
      4. Redirige vers Ren0vate pour l'accompagnement détaillé
      5. Si tu ne sais pas, dis-le et propose de contacter un expert humain

      STYLE:
      - Professionnel mais accessible
      - Utilise des exemples concrets
      - Structure tes réponses clairement
      - Propose des boutons d'action quand pertinent

      Tu as accès aux données temps réel des subsides belges et aux spécificités régionales.
    PROMPT
  end

  def recent_conversation_history(limit: 6)
    messages = @conversation.messages_array
    messages.last(limit).map do |msg|
      {
        role: msg['role'],
        content: msg['content'].truncate(200),
        timestamp: msg['timestamp']
      }
    end
  end

  def get_regional_context
    region = @conversation.user_region || @config.dig(:regions, :default)

    case region
    when 'wallonie'
      {
        name: 'Wallonie',
        authority: 'Région wallonne',
        language: 'fr',
        specific_programs: ['Rénopack', 'Prime Habitation', 'Audits énergétiques'],
        contact_info: 'Service Public de Wallonie'
      }
    when 'flandre'
      {
        name: 'Flandre',
        authority: 'Vlaams Gewest',
        language: 'nl',
        specific_programs: ['Vlaamse renovatiepremie', 'Energiepremie'],
        contact_info: 'Vlaams Energie- en Klimaatagentschap'
      }
    when 'bruxelles'
      {
        name: 'Bruxelles-Capitale',
        authority: 'Région de Bruxelles-Capitale',
        language: 'fr/nl',
        specific_programs: ['Prime Renolution', 'Prime énergie'],
        contact_info: 'Bruxelles Environnement'
      }
    else
      {
        name: 'Belgique',
        authority: 'National',
        language: 'fr/nl',
        specific_programs: [],
        contact_info: 'Service fédéral'
      }
    end
  end

  def get_relevant_subsidies(intent_analysis)
    # TODO: Implémenter la recherche dans la base de données des 324 subsides
    # Pour l'instant, on retourne des exemples selon l'intent
    case intent_analysis[:category]
    when 'isolation'
      build_isolation_subsidies
    when 'chauffage'
      build_heating_subsidies
    when 'renovation_generale'
      build_general_renovation_subsidies
    else
      build_default_subsidies
    end
  end

  def generate_ai_response(user_message, context)
    messages = [
      { role: 'system', content: context[:system_prompt] },
      *context[:conversation_history],
      { role: 'user', content: user_message }
    ]

    response = @openai_client.chat(
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

  def enhance_response(ai_content, intent_analysis)
    # Enrichir la réponse avec des actions suggérées
    actions = build_suggested_actions(intent_analysis)

    {
      content: ai_content,
      actions: actions,
      metadata: {
        intent: intent_analysis,
        response_type: determine_response_type(ai_content),
        timestamp: Time.current.iso8601,
        model_used: @config.dig(:openai, :model)
      }
    }
  end

  def build_suggested_actions(intent_analysis)
    actions = []

    case intent_analysis[:category]
    when 'isolation', 'chauffage', 'renovation_generale'
      actions << {
        type: 'form',
        label: 'Calculer mes primes exactes',
        url: "/contacts/#{@conversation.user_type || 'particuliers'}",
        primary: true
      }
      actions << {
        type: 'redirect',
        label: 'Être accompagné par un expert',
        url: build_renovate_url,
        primary: false
      }
    when 'information_generale'
      actions << {
        type: 'internal',
        label: 'En savoir plus sur notre équipe',
        url: '/about',
        primary: false
      }
    end

    actions << {
      type: 'contact',
      label: 'Parler à un expert humain',
      url: 'mailto:equipe@primes-services.be',
      primary: false
    }

    actions
  end

  def build_renovate_url
    base_url = @config.dig(:integrations, :renovate_base_url)
    params = {
      source: 'ps',
      profile: @conversation.user_type || 'particulier',
      region: @conversation.user_region || 'auto'
    }

    "#{base_url}?#{params.to_query}"
  end

  def determine_response_type(content)
    return 'calculation' if content.match?(/€|EUR|euros?/i)
    return 'procedure' if content.match?(/étapes?|démarches?|procédure/i)
    return 'information' if content.match?(/conditions?|critères?/i)
    'general'
  end

  # Méthodes utilitaires pour les subsides (à enrichir avec vraie DB)
  def build_isolation_subsidies
    [
      {
        name: "Prime isolation Wallonie",
        amount: "Jusqu'à 6 000€",
        conditions: "Selon revenus et type d'isolation",
        region: "wallonie"
      }
    ]
  end

  def build_heating_subsidies
    [
      {
        name: "Prime pompe à chaleur",
        amount: "Jusqu'à 4 500€",
        conditions: "Remplacement ancien système",
        region: @conversation.user_region
      }
    ]
  end

  def build_general_renovation_subsidies
    [
      {
        name: "Rénopack Wallonie",
        amount: "Jusqu'à 30 000€",
        conditions: "Rénovation globale",
        region: "wallonie"
      }
    ]
  end

  def build_default_subsidies
    []
  end

  # Gestion des erreurs et logging
  def handle_error(error, user_message)
    log_error "AiChatbotService Error", error, { user_message: user_message }

    error_response(
      "Je suis désolé, je rencontre une difficulté. Un expert peut vous aider : equipe@primes-services.be"
    )
  end

  def success_response(data)
    {
      success: true,
      data: data,
      conversation_id: @conversation.session_id
    }
  end

  def error_response(message)
    {
      success: false,
      error: message,
      conversation_id: @conversation&.session_id
    }
  end

  def log_debug(message, data = {})
    @logger.debug "[AiChatbot] #{message}: #{data.inspect}" if @config.dig(:debug, :enabled)
  end

  def log_error(message, error, data = {})
    @logger.error "[AiChatbot] #{message}: #{error.message}"
    @logger.error error.backtrace.join("\n") if @config.dig(:debug, :enabled)
    @logger.error "Context: #{data.inspect}" if data.any?
  end

  def benchmark(message, &block)
    if @config.dig(:debug, :enabled)
      super(message, level: :debug, &block)
    else
      yield
    end
  end
end

class AiController < ApplicationController
  before_action :setup_ai_service
  before_action :validate_session, only: [:chat]

  # GET /ai/chat - Interface de chat principal
  def chat
    @conversation_stats = @ai_service.conversation_stats
    @conversation_history = @ai_service.conversation_history
  end

  # POST /ai/chat - Traitement d'un message utilisateur
  def send_message
    message = params[:message]&.strip
    user_metadata = extract_user_metadata

    if message.blank?
      render json: {
        success: false,
        error: "Message vide"
      }, status: 422
      return
    end

    begin
      result = @ai_service.process_message(message, metadata: user_metadata)

      if result[:success]
        render json: {
          success: true,
          message: result[:data][:content],
          actions: result[:data][:actions],
          metadata: result[:data][:metadata],
          conversation_id: result[:conversation_id]
        }
      else
        render json: {
          success: false,
          error: result[:error],
          conversation_id: result[:conversation_id]
        }, status: 422
      end

    rescue => e
      Rails.logger.error "[AiController] Error processing message: #{e.message}"
      render json: {
        success: false,
        error: "Erreur technique. Veuillez réessayer."
      }, status: 500
    end
  end

  # GET /ai/history - Historique de conversation
  def history
    @conversation_history = @ai_service.conversation_history
    @conversation_stats = @ai_service.conversation_stats

    respond_to do |format|
      format.html
      format.json {
        render json: {
          history: @conversation_history,
          stats: @conversation_stats
        }
      }
    end
  end

  # POST /ai/reset - Réinitialisation de conversation
  def reset
    @ai_service.reset_conversation!

    respond_to do |format|
      format.html { redirect_to ai_chat_path, notice: "Conversation réinitialisée" }
      format.json { render json: { success: true, message: "Conversation réinitialisée" } }
    end
  end

  # GET /ai/stats - Statistiques de conversation
  def stats
    @stats = @ai_service.conversation_stats
    @analytics = gather_conversation_analytics

    respond_to do |format|
      format.html
      format.json { render json: { stats: @stats, analytics: @analytics } }
    end
  end

  # POST /ai/complete - Marquer conversation comme terminée
  def complete
    @ai_service.complete_conversation!

    respond_to do |format|
      format.html { redirect_to root_path, notice: "Merci pour votre visite !" }
      format.json { render json: { success: true, message: "Conversation terminée" } }
    end
  end

  # GET /ai/suggestions - Suggestions contextuelles
  def suggestions
    user_profile = {
      type: session[:user_type],
      region: session[:user_region] || detect_user_region
    }

    nlp = NaturalLanguageProcessor.new
    recent_message = @ai_service.conversation_history.last&.dig('content') || ""
    analysis = nlp.analyze(recent_message, user_profile)

    render json: {
      suggestions: analysis[:suggestions],
      intent: analysis[:intent][:category],
      confidence: analysis[:confidence]
    }
  end

  private

  def setup_ai_service
    @ai_service = AiChatbotService.new(
      session_id: session[:ai_conversation_id],
      user_type: session[:user_type] || params[:user_type],
      user_region: session[:user_region] || params[:user_region] || detect_user_region
    )

    # Sauvegarder l'ID de conversation en session
    session[:ai_conversation_id] = @ai_service.conversation.session_id
    session[:user_type] ||= params[:user_type]
    session[:user_region] ||= params[:user_region] || detect_user_region
  end

  def validate_session
    # Validation basique - peut être étendue selon les besoins
    if session[:ai_conversation_id].blank?
      setup_ai_service
    end
  end

  def extract_user_metadata
    {
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      referer: request.referer,
      session_id: session.id,
      timestamp: Time.current.iso8601,
      user_type: session[:user_type],
      user_region: session[:user_region],
      page_url: params[:page_url],
      client_timezone: params[:timezone]
    }
  end

  def detect_user_region
    # Détection basique par IP - peut être améliorée
    # Pour l'instant, retourne la région par défaut
    Rails.application.config.ai.dig(:regions, :default) || 'wallonie'
  end

  def gather_conversation_analytics
    conversation = @ai_service.conversation

    {
      total_messages: conversation.message_count,
      conversation_duration: conversation.duration_minutes,
      user_engagement: calculate_engagement_score(conversation),
      popular_intents: extract_popular_intents(conversation),
      conversion_signals: detect_conversion_signals(conversation)
    }
  end

  def calculate_engagement_score(conversation)
    messages = conversation.messages_array
    return 0 if messages.empty?

    user_messages = messages.select { |m| m['role'] == 'user' }

    # Score basé sur nombre de messages et longueur moyenne
    message_score = [user_messages.count / 10.0, 1.0].min
    length_score = user_messages.map { |m| m['content'].length }.sum / [user_messages.count * 50.0, 1.0].max

    ((message_score + length_score) / 2 * 100).round
  end

  def extract_popular_intents(conversation)
    # Analyser les intents des messages utilisateur
    nlp = NaturalLanguageProcessor.new
    user_messages = conversation.messages_array.select { |m| m['role'] == 'user' }

    intents = user_messages.map do |message|
      analysis = nlp.analyze(message['content'])
      analysis[:intent][:category]
    end

    # Compter les occurrences
    intent_counts = intents.group_by(&:itself).transform_values(&:count)
    intent_counts.sort_by { |_, count| -count }.first(3)
  end

  def detect_conversion_signals(conversation)
    signals = []
    user_messages = conversation.messages_array.select { |m| m['role'] == 'user' }

    user_messages.each do |message|
      content = message['content'].downcase

      signals << 'contact_request' if content.match?(/contact|téléphone|email|rendez-vous/)
      signals << 'calculation_request' if content.match?(/calculer|combien|montant|estimation/)
      signals << 'form_interest' if content.match?(/formulaire|dossier|demande/)
      signals << 'expert_request' if content.match?(/expert|humain|personne|conseiller/)
    end

    signals.uniq
  end
end

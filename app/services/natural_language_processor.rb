# Service de traitement du langage naturel pour primes-services.ia
# Analyse l'intent des messages utilisateurs et extrait les informations pertinentes
class NaturalLanguageProcessor
  
  # Catégories principales d'intent pour les subsides
  INTENT_CATEGORIES = {
    isolation: {
      keywords: %w[isoler isolation isolant combles murs façade toiture laine verre polyurethane],
      synonyms: %w[isoler calorifuger thermique phonique],
      weight: 1.0
    },
    chauffage: {
      keywords: %w[chauffage chaudière pompe chaleur gaz mazout électrique radiateurs],
      synonyms: %w[heating climatisation ventilation],
      weight: 1.0
    },
    renovation_generale: {
      keywords: %w[rénover rénovation travaux maison appartement logement réhabilitation],
      synonyms: %w[restaurer moderniser transformer],
      weight: 0.8
    },
    energie_renouvelable: {
      keywords: %w[solaire photovoltaique eolienne biomasse géothermie],
      synonyms: %w[renouvelable verte écologique],
      weight: 1.0
    },
    aide_financiere: {
      keywords: %w[prime subside aide financement crédit prêt montant budget],
      synonyms: %w[subsides primes allocations],
      weight: 0.9
    },
    procedure: {
      keywords: %w[comment démarche procédure étapes dossier formulaire],
      synonyms: %w[process faire obtenir demander],
      weight: 0.7
    },
    information_generale: {
      keywords: %w[qui équipe entreprise société contact téléphone],
      synonyms: %w[about propos informations],
      weight: 0.5
    }
  }.freeze

  # Régions belges et leurs variantes
  REGIONS = {
    wallonie: %w[wallonie wallon wallons liège namur charleroi mons tournai],
    flandre: %w[flandre flamand flamands anvers gand bruges louvain],
    bruxelles: %w[bruxelles capitale région uccle ixelles schaerbeek]
  }.freeze

  # Types de biens immobiliers
  PROPERTY_TYPES = {
    maison: %w[maison villa cottage fermette],
    appartement: %w[appartement flat studio duplex],
    immeuble: %w[immeuble bâtiment copropriété syndic],
    commercial: %w[bureau local commercial magasin entrepôt]
  }.freeze

  def initialize
    @logger = Rails.logger
  end

  # Analyse principale du message utilisateur
  def analyze(message, user_profile = {})
    return default_analysis if message.blank?

    analysis = {
      original_message: message,
      cleaned_message: clean_message(message),
      intent: extract_intent(message),
      entities: extract_entities(message),
      user_context: analyze_user_context(user_profile),
      confidence: 0.0,
      suggestions: []
    }

    # Calcul de la confiance globale
    analysis[:confidence] = calculate_confidence(analysis)
    
    # Ajout de suggestions basées sur l'analyse
    analysis[:suggestions] = generate_suggestions(analysis)

    log_analysis(analysis) if Rails.application.config.ai.dig(:debug, :enabled)
    
    analysis
  end

  private

  def clean_message(message)
    # Normalisation du texte
    cleaned = message.downcase
    cleaned = cleaned.gsub(/[^\w\s\-àâäçéèêëïîôùûüÿñæœ]/, ' ')
    cleaned = cleaned.gsub(/\s+/, ' ').strip
    cleaned
  end

  def extract_intent(message)
    cleaned = clean_message(message)
    words = cleaned.split(/\s+/)
    
    # Calcul des scores pour chaque catégorie
    category_scores = {}
    
    INTENT_CATEGORIES.each do |category, config|
      score = calculate_category_score(words, config)
      category_scores[category] = score if score > 0
    end

    # Détermination de la catégorie principale
    if category_scores.any?
      primary_category = category_scores.max_by { |_, score| score }[0]
      confidence = category_scores[primary_category]
    else
      primary_category = :information_generale
      confidence = 0.3
    end

    {
      category: primary_category,
      confidence: confidence,
      all_scores: category_scores,
      detected_keywords: extract_matched_keywords(words),
      question_type: detect_question_type(message)
    }
  end

  def calculate_category_score(words, config)
    score = 0.0
    matched_keywords = 0

    # Score basé sur les mots-clés principaux
    config[:keywords].each do |keyword|
      if words.include?(keyword)
        score += config[:weight]
        matched_keywords += 1
      end
    end

    # Score basé sur les synonymes (pondéré)
    config[:synonyms].each do |synonym|
      if words.include?(synonym)
        score += config[:weight] * 0.7
        matched_keywords += 1
      end
    end

    # Bonus pour plusieurs mots-clés de la même catégorie
    score *= (1 + (matched_keywords - 1) * 0.2) if matched_keywords > 1

    score
  end

  def extract_matched_keywords(words)
    matched = []
    
    INTENT_CATEGORIES.each do |category, config|
      keywords = config[:keywords] & words
      synonyms = config[:synonyms] & words
      matched << { category: category, keywords: keywords, synonyms: synonyms } if keywords.any? || synonyms.any?
    end

    matched
  end

  def detect_question_type(message)
    return :question_amount if message.match?(/combien|montant|prix|coût|euros?|€/i)
    return :question_how if message.match?(/comment|procédure|démarche|étapes/i)
    return :question_eligibility if message.match?(/puis-je|ai-je droit|éligible|conditions/i)
    return :question_where if message.match?(/où|adresse|contact|bureau/i)
    return :question_when if message.match?(/quand|délai|temps|durée/i)
    return :question_what if message.match?(/qu(e|oi)|quel/i)
    return :request_calculation if message.match?(/calculer|estimer|simulation/i)
    
    :statement
  end

  def extract_entities(message)
    {
      regions: extract_regions(message),
      property_types: extract_property_types(message),
      amounts: extract_amounts(message),
      timeframes: extract_timeframes(message),
      contact_info: extract_contact_preferences(message)
    }
  end

  def extract_regions(message)
    detected = []
    cleaned = clean_message(message)
    
    REGIONS.each do |region, keywords|
      if keywords.any? { |keyword| cleaned.include?(keyword) }
        detected << region
      end
    end

    detected.uniq
  end

  def extract_property_types(message)
    detected = []
    cleaned = clean_message(message)
    
    PROPERTY_TYPES.each do |type, keywords|
      if keywords.any? { |keyword| cleaned.include?(keyword) }
        detected << type
      end
    end

    detected.uniq
  end

  def extract_amounts(message)
    amounts = []
    
    # Recherche des montants en euros
    message.scan(/(\d+(?:[.,]\d+)?)\s*(?:€|euros?|eur)/i) do |match|
      amounts << {
        value: match[0].gsub(',', '.').to_f,
        currency: 'EUR',
        context: :mentioned_amount
      }
    end

    # Recherche des budgets approximatifs
    if message.match?(/petit budget|budget serré/i)
      amounts << { value: 5000, currency: 'EUR', context: :budget_range, type: :low }
    elsif message.match?(/gros budget|budget important/i)
      amounts << { value: 50000, currency: 'EUR', context: :budget_range, type: :high }
    end

    amounts
  end

  def extract_timeframes(message)
    timeframes = []
    
    timeframes << :urgent if message.match?(/urgent|rapidement|vite|asap/i)
    timeframes << :this_year if message.match?(/cette année|2025/i)
    timeframes << :flexible if message.match?(/pas pressé|flexible|quand possible/i)

    timeframes
  end

  def extract_contact_preferences(message)
    preferences = []
    
    preferences << :phone if message.match?(/téléphone|appeler|tel/i)
    preferences << :email if message.match?(/email|mail|courriel/i)
    preferences << :meeting if message.match?(/rendez-vous|rencontre|bureau/i)
    preferences << :human_contact if message.match?(/parler|humain|personne|expert/i)

    preferences
  end

  def analyze_user_context(user_profile)
    context = {
      user_type: user_profile[:type],
      region: user_profile[:region],
      previous_interactions: user_profile.dig(:metadata, :interaction_count) || 0,
      expertise_level: determine_expertise_level(user_profile)
    }

    # Adaptation du contexte selon le type d'utilisateur
    case user_profile[:type]
    when 'particulier'
      context[:focus] = :individual_subsidies
      context[:complexity] = :simple
    when 'acp'
      context[:focus] = :building_management
      context[:complexity] = :medium
    when 'entreprise_immo', 'entreprise_comm'
      context[:focus] = :business_subsidies
      context[:complexity] = :advanced
    else
      context[:focus] = :general_information
      context[:complexity] = :simple
    end

    context
  end

  def determine_expertise_level(user_profile)
    interaction_count = user_profile.dig(:metadata, :interaction_count) || 0
    
    return :expert if interaction_count > 10
    return :intermediate if interaction_count > 3
    :beginner
  end

  def calculate_confidence(analysis)
    intent_confidence = analysis[:intent][:confidence]
    entity_bonus = analysis[:entities].values.flatten.count * 0.1
    context_bonus = analysis[:user_context][:previous_interactions] > 0 ? 0.1 : 0

    confidence = intent_confidence + entity_bonus + context_bonus
    [confidence, 1.0].min # Cap à 100%
  end

  def generate_suggestions(analysis)
    suggestions = []
    
    case analysis[:intent][:category]
    when :isolation
      suggestions << "Voulez-vous connaître les primes pour l'isolation de votre région ?"
      suggestions << "Souhaitez-vous calculer le montant exact de vos primes ?"
    when :chauffage
      suggestions << "Quel type de chauffage vous intéresse ?"
      suggestions << "Voulez-vous comparer les différentes options ?"
    when :aide_financiere
      suggestions << "Souhaitez-vous une estimation personnalisée ?"
      suggestions << "Voulez-vous connaître toutes les aides disponibles ?"
    when :procedure
      suggestions << "Voulez-vous que je vous guide étape par étape ?"
      suggestions << "Souhaitez-vous être mis en contact avec un expert ?"
    end

    # Suggestions basées sur les entités détectées
    if analysis[:entities][:regions].any?
      region = analysis[:entities][:regions].first
      suggestions << "Je peux vous donner des informations spécifiques à la #{region}"
    end

    if analysis[:entities][:contact_info].include?(:human_contact)
      suggestions << "Voulez-vous être contacté par un expert humain ?"
    end

    suggestions.uniq
  end

  def default_analysis
    {
      original_message: "",
      cleaned_message: "",
      intent: {
        category: :information_generale,
        confidence: 0.0,
        all_scores: {},
        detected_keywords: [],
        question_type: :statement
      },
      entities: {
        regions: [],
        property_types: [],
        amounts: [],
        timeframes: [],
        contact_info: []
      },
      user_context: {},
      confidence: 0.0,
      suggestions: ["Comment puis-je vous aider avec les primes et subsides ?"]
    }
  end

  def log_analysis(analysis)
    @logger.debug "[NLP] Intent Analysis: #{analysis[:intent]}"
    @logger.debug "[NLP] Entities: #{analysis[:entities]}"
    @logger.debug "[NLP] Confidence: #{analysis[:confidence]}"
  end
end
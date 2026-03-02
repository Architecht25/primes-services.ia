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
    user_region = @conversation.user_region
    user_type = @conversation.user_type || "visiteur"
    regional_info = get_regional_context

    <<~PROMPT
      Tu es #{assistant_name}, l'assistant IA spécialisé en primes de rénovation énergétique et prêts à taux 0% pour TOUTE LA BELGIQUE.

      IMPORTANT: Tu couvres les 3 régions belges - Wallonie, Flandre ET Bruxelles-Capitale.
      Ne te limite JAMAIS à une seule région dans tes réponses de bienvenue.

      CONTEXTE UTILISATEUR:
      - Profil: #{user_type}
      - Région: #{user_region || 'Non spécifiée - DEMANDER à l\'utilisateur'}
      - Langue: #{@config.dig(:assistant, :language)}

      TON EXPERTISE COUVRE LES 3 RÉGIONS BELGES:
      ✓ Wallonie (Primes Habitation, Prêts SWCS 0%, Monuments et Sites, Primes Communales, Audit Énergétique)
      ✓ Flandre (Renovatiepremie, Mijn VerbouwLening 0-1.5%, Erfgoed, Communale premies, PEB)
      ✓ Bruxelles-Capitale (Renolution, Crédit EcoRéno 2.5-3.5%, Monuments et Sites, Petit Patrimoine, Primes Communales)

      INFORMATION RÉGIONALE DE RÉFÉRENCE (#{regional_info[:name]}):

      1. EXEMPLES DE PRIMES (disponibles aussi dans les autres régions):
      #{regional_info[:specific_subsidies]&.map { |s| "   • #{s}" }&.join("\n") || "   • Primes régionales standard"}

      2. PRIMES SPÉCIFIQUES:
      #{regional_info[:special_primes]&.map { |s| "   • #{s}" }&.join("\n") || "   • Contactez-moi pour plus d'infos"}

      3. PRÊTS & FINANCEMENTS:
      #{regional_info[:loan_programs]&.map { |s| "   • #{s}" }&.join("\n") || "   • Prêts verts disponibles"}

      TON RÔLE PRINCIPAL:
      - Répondre avec précision sur TOUTES les régions belges (Wallonie, Flandre, Bruxelles)
      - NE JAMAIS limiter tes réponses à une seule région dans ton message d'accueil
      - Demander à l'utilisateur sa région si non spécifiée dans sa question
      - Évaluer l'éligibilité aux primes selon le profil et la région
      - Calculer les montants estimés des primes disponibles
      - Expliquer les conditions d'obtention (revenus, travaux, démarches)
      - Conseiller sur les prêts à taux 0% et solutions de financement
      - Identifier les primes cumulables (régionales + communales + spécifiques)
      - Orienter vers les simulateurs de l'application pour calculs précis
      - Rediriger vers Ren0vate pour l'accompagnement complet du projet

      RÈGLES IMPORTANTES:
      1. Tu connais TOUTE la Belgique - Wallonie, Flandre ET Bruxelles à parts égales
      2. DANS TON MESSAGE D'ACCUEIL: Mentionne TOUJOURS les 3 régions, jamais une seule
      3. Si l'utilisateur ne précise pas sa région, demande-lui
      4. Réponds TOUJOURS en français belge (#{@config.dig(:assistant, :language)})
      5. Pour les montants et conditions PRÉCIS, réfère SYSTÉMATIQUEMENT aux pages de l'app ci-dessus
      6. Les pages /simulation/{région}/primes et /prets contiennent TOUTES les infos officielles 2026
      7. TOUJOURS suggérer d'utiliser les calculateurs et simulateurs de l'app pour calculs exacts
      8. Mentionne les SOURCES OFFICIELLES (SWCS, Mijn VerbouwLening, Fonds du Logement, etc.)
      9. Propose des ACTIONS CONCRÈTES: consulter la page des primes, utiliser le simulateur, contacter l'organisme
      10. Recommande Ren0vate (/renovate) pour l'accompagnement personnalisé de A à Z
      11. Si tu ne connais pas un détail précis, oriente vers les pages de l'app ou vers un expert
      12. Utilise les informations régionales fournies dans ton contexte mais renvoie vers les pages pour les détails

      PAGES DE L'APPLICATION À RÉFÉRENCER (informations détaillées disponibles):

      PRIMES par région:
      - /simulation/wallonie/primes : Calculateur primes + Prime Audit + Prime Monuments & Sites + Primes Communales
      - /simulation/flandre/primes : Calculateur primes + Prime PEB + Prime Monuments & Sites + Primes Communales
      - /simulation/bruxelles/primes : Calculateur primes + Prime Petit Patrimoine + Prime Monuments & Sites + Primes Communales

      PRÊTS par région (informations officielles 2026):
      - /simulation/wallonie/prets : 3 prêts SWCS à 0% (Rénopack 1-60k€, Rénopack SWCS 1-30k€, Rénoprêt 1-30k€) + conditions détaillées
      - /simulation/flandre/prets : Mijn VerbouwLening 4-60k€ avec taux variable 0-1.5% selon revenus + nouveautés 2026 + conditions
      - /simulation/bruxelles/prets : Crédit EcoRéno - Hypothécaire (max 120% valeur) et Consommation (1.5-25k€) à 2.5-3.5% + conditions

      ACCOMPAGNEMENT:
      - /renovate : Plateforme Ren0vate pour accompagnement complet du projet de A à Z

      ⚠️ IMPORTANT: Oriente SYSTÉMATIQUEMENT les utilisateurs vers ces pages pour consulter:
      - Les montants EXACTS des primes selon leur profil
      - Les CONDITIONS DÉTAILLÉES d'éligibilité (revenus, logement, travaux)
      - Les SIMULATEURS en ligne pour calculs précis
      - Les LIENS vers organismes officiels et formulaires de demande

      STYLE DE COMMUNICATION:
      - Professionnel mais chaleureux et accessible
      - Utilise des EXEMPLES CONCRETS avec montants
      - Structure tes réponses clairement (listes, sections)
      - Mentionne toujours les montants estimés quand possible
      - Identifie les primes CUMULABLES pour maximiser les aides
      - Termine avec des boutons d'action pertinents

      EXPERTISE: Connaissance approfondie des primes régionales, communales, spécifiques (monuments, patrimoine, audit/PEB) et prêts à taux 0% dans TOUTE la Belgique (Wallonie, Flandre, Bruxelles).
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
    region = @conversation.user_region

    case region
    when 'wallonie'
      {
        name: 'Wallonie',
        authority: 'Région wallonne',
        language: 'fr',
        specific_programs: ['Rénopack', 'Prime Habitation', 'Audits énergétiques'],
        specific_subsidies: [
          'Isolation de toiture : jusqu\'à 30€/m² (50€/m² revenus modestes)',
          'Isolation des murs : jusqu\'à 70€/m² selon technique',
          'Pompe à chaleur : 4 000€ à 6 000€',
          'Chaudière biomasse : 3 000€ à 5 000€',
          'Panneaux photovoltaïques : prime selon kWc installé',
          'Ventilation double flux : 1 800€ à 2 500€'
        ],
        special_primes: [
          'Prime Monuments et Sites : jusqu\'à 80% du coût pour biens classés',
          'Primes Communales : 500€ à 5 000€ selon la commune (200+ communes)',
          'Prime Audit Énergétique : 110€ à 660€ selon type d\'audit',
          'Possibilité de cumul primes régionales + communales'
        ],
        loan_programs: [
          'Prêts SWCS (Société Wallonne du Crédit Social) à 0% - 3 formules:',
          '  • Rénopack : 1 000€ à 60 000€, avec audit énergétique obligatoire, max 30 ans',
          '  • Rénopack SWCS : 1 000€ à 30 000€, pour toiture et électricité (sans audit), max 15 ans',
          '  • Rénoprêt : 1 000€ à 30 000€, sans primes, audits ni PEB, max 15 ans',
          'Conditions SWCS : RIG < 122 827€, logement 15+ ans, mensualité min 75€',
          'Contact : SWCS - https://www.swcs.be/ - Fédération du Logement Wallonie'
        ],
        contact_info: 'Service Public de Wallonie',
        official_urls: {
          main: 'https://energie.wallonie.be/',
          prime_habitation: 'https://energie.wallonie.be/fr/prime-habitation.html',
          audit_energetique: 'https://energie.wallonie.be/fr/audit-energetique.html',
          isolation: 'https://energie.wallonie.be/fr/prime-isolation.html',
          chauffage: 'https://energie.wallonie.be/fr/prime-chauffage.html',
          renovation: 'https://energie.wallonie.be/fr/prime-renovation.html',
          monuments: 'https://www.awap.be/',
          primes_communales: 'https://energie.wallonie.be/fr/primes-communales.html'
        },
        key_info: 'Les primes wallonnes sont modulées selon les revenus. Possibilité de cumuler primes régionales + communales + spécifiques.'
      }
    when 'flandre'
      {
        name: 'Flandre',
        authority: 'Vlaams Gewest',
        language: 'nl',
        specific_programs: ['Vlaamse renovatiepremie', 'Energiepremie', 'Verbouwpremie'],
        specific_subsidies: [
          'Dakisolatie (isolation toiture) : jusqu\'à 30€/m²',
          'Muurisolatie (isolation murs) : jusqu\'à 50€/m²',
          'Warmtepomp (pompe à chaleur) : jusqu\'à 4 500€',
          'Zonnepanelen (panneaux solaires) : primes selon installation',
          'Ventilatiesysteem (ventilation) : jusqu\'à 2 000€',
          'Hoogrendementsglas (châssis performants) : prime selon m²'
        ],
        special_primes: [
          'Prime Patrimoine (Onroerend Erfgoed) : jusqu\'à 80% pour biens classés',
          'Primes Communales flamandes : 300€ à 4 000€ selon commune (150+ communes)',
          'Prime Certificat PEB/EPC : jusqu\'à 100€ pour certification énergétique',
          'Possibilité de cumul primes régionales + communales + patrimoine'
        ],
        loan_programs: [
          'Mijn VerbouwLening (Prêt Rénovation 2026) - Taux variable selon revenus:',
          '  • Montant : 4 000€ à 60 000€ (max 125% coût travaux)',
          '  • Taux par catégorie : Cat 4 ≥0% (réduction 5%), Cat 3 ≈0.5% (réduction 4%), Cat 2 ≈1.5% (réduction 3%)',
          '  • Nouveautés 2026 : Bonus +2% (cat 4) et +1% (cat 3) sur réductions',
          '  • Durée : max 30 ans, remboursement avant 75 ans',
          'Conditions : Logement 20+ ans Flandre, revenus cadastraux < 3 000€, travaux via Mijn VerbouwLoket',
          'Contact : mijnverbouwlening@vlaanderen.be - https://apps.energiesparen.be/simulator-mijnverbouwlening'
        ],
        contact_info: 'Vlaams Energie- en Klimaatagentschap (VEKA)',
        official_urls: {
          main: 'https://www.vlaanderen.be/',
          renovation: 'https://www.vlaanderen.be/premies-voor-verbouwingen',
          energie: 'https://www.vlaanderen.be/bouwen-wonen-en-energie',
          isolation: 'https://www.vlaanderen.be/premie-voor-isolatie',
          chauffage: 'https://www.vlaanderen.be/premie-voor-verwarmingsinstallatie',
          patrimoine: 'https://www.onroerenderfgoed.be/',
          peb: 'https://www.energiesparen.be/epb-peb'
        },
        key_info: 'Les primes flamandes dépendent des revenus du ménage. Le certificat PEB est souvent obligatoire. Cumul possible des primes régionales, communales et patrimoine.'
      }
    when 'bruxelles'
      {
        name: 'Bruxelles-Capitale',
        authority: 'Région de Bruxelles-Capitale',
        language: 'fr/nl',
        specific_programs: ['Renolution', 'Prime Énergie', 'Prime Rénovation'],
        specific_subsidies: [
          'Isolation de toiture : jusqu\'à 50€/m² (75€/m² revenus modestes)',
          'Isolation des murs : jusqu\'à 100€/m² selon technique',
          'Pompe à chaleur : jusqu\'à 4 500€ (primes majorées possibles)',
          'Chaudière condensation : 2 000€ à 3 500€',
          'Panneaux photovoltaïques : 350€ à 500€/kWc',
          'Ventilation double flux : jusqu\'à 3 500€',
          'Châssis performants : jusqu\'à 120€/m²'
        ],
        special_primes: [
          'Prime Monuments et Sites : jusqu\'à 90% pour biens classés (urban.brussels)',
          'Primes Communales : 400€ à 6 000€ (19 communes bruxelloises)',
          'Prime Petit Patrimoine : jusqu\'à 50% (max 5 000€) pour éléments remarquables',
          'Prime embellissement façade : jusqu\'à 80% selon commune',
          'Cumul possible : primes régionales + communales + patrimoine'
        ],
        loan_programs: [
          'Crédit EcoRéno (Fonds du Logement Bruxelles) - 2 formules au choix:',
          '  1. CRÉDIT HYPOTHÉCAIRE : jusqu\'à 120% valeur bien, max 30 ans, frais 384€ + notaire',
          '  2. CRÉDIT CONSOMMATION : 1 500€ à 25 000€, max 10 ans, AUCUN FRAIS, pas d\'hypothèque',
          '  • Taux 2026 : 2,5% (revenus bas: isolé <45,6k€, ménage <60,6k€) ou 3,5% (revenus moyens: isolé 45,6-73,9k€, ménage 60,6-94k€)',
          '  • Mensualité minimum : 25€',
          '  • Cumulable avec primes Renolution (déduction automatique)',
          'Conditions : Résider à Bruxelles, bien dans les 19 communes, remboursement avant 70 ans',
          'Contact : infopret@fonds.brussels - Simulateur: https://websimu.wffl.be/ecoreno/lang/fr'
        ],
        contact_info: 'Bruxelles Environnement / Leefmilieu Brussel',
        official_urls: {
          main: 'https://www.bruxellesenvironnement.be/',
          primes: 'https://www.bruxellesenvironnement.be/particuliers/mes-aides-financieres-et-primes',
          renolution: 'https://www.renolution.brussels/',
          isolation: 'https://www.bruxellesenvironnement.be/particuliers/mes-aides-financieres-et-primes/prime-energie/isolation',
          chauffage: 'https://www.bruxellesenvironnement.be/particuliers/mes-aides-financieres-et-primes/prime-energie/chauffage',
          monuments: 'https://urban.brussels/fr/nos-themes/patrimoine-et-monuments',
          primes_communales: 'https://1819.brussels/infotheque/primes-aides-subventions/renovation/primes-communales-bruxelles'
        },
        key_info: 'Bruxelles offre les primes les plus généreuses de Belgique, surtout pour les revenus modestes. Les primes communales peuvent significativement augmenter le montant total. Cumul possible entre plusieurs dispositifs.'
      }
    else
      {
        name: 'Belgique (Wallonie, Flandre, Bruxelles)',
        authority: 'Multi-régional',
        language: 'fr/nl',
        specific_programs: ['Primes régionales disponibles dans les 3 régions'],
        specific_subsidies: [
          'Wallonie : Isolation toiture 30€/m², Pompe à chaleur 4-6k€, Primes communales 500-5k€',
          'Flandre : Dakisolatie 30€/m², Warmtepomp 4,5k€, Communale premies 300-4k€',
          'Bruxelles : Isolation toiture 50-75€/m², Pompe à chaleur 4,5k€, Primes communales 400-6k€'
        ],
        special_primes: [
          'Primes Monuments et Sites disponibles dans les 3 régions (jusqu\'à 80-90% du coût)',
          'Primes Communales : 500+ communes offrent des aides supplémentaires',
          'Cumul possible : primes régionales + communales + patrimoine dans toutes les régions'
        ],
        loan_programs: [
          'Wallonie : Prêts SWCS à 0% - Rénopack (1-60k€, avec audit), Rénopack SWCS (1-30k€, toiture/électricité), Rénoprêt (1-30k€, sans primes)',
          'Flandre : Mijn VerbouwLening 0-1,5% selon revenus (4-60k€, nouveautés 2026 avec bonus)',
          'Bruxelles : Crédit EcoRéno 2,5-3,5% - Hypothécaire (max 120% valeur) ou Consommation (1,5-25k€, sans frais)',
          'Toutes régions : Prêts verts bancaires et solutions de financement'
        ],
        contact_info: 'Services régionaux selon votre localisation',
        official_urls: {},
        key_info: 'Les 3 régions belges offrent des primes généreuses. Demandez à l\'utilisateur sa région pour des informations précises.'
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
    # Enrichir la réponse avec des actions suggérées et les liens officiels
    actions = build_suggested_actions(intent_analysis)
    enhanced_content = add_official_links(ai_content, intent_analysis)

    {
      content: enhanced_content,
      actions: actions,
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
      relevant_links << ({ text: "Prime isolation", url: regional_info[:official_urls][:isolation] }) if regional_info[:official_urls][:isolation]
    when :chauffage
      relevant_links << ({ text: "Prime chauffage", url: regional_info[:official_urls][:chauffage] }) if regional_info[:official_urls][:chauffage]
    when :renovation_generale, :aide_financiere
      relevant_links << ({ text: "Prime rénovation", url: regional_info[:official_urls][:renovation] }) if regional_info[:official_urls][:renovation]
      relevant_links << ({ text: "Prime habitation", url: regional_info[:official_urls][:prime_habitation] }) if regional_info[:official_urls][:prime_habitation]
    when :audit_energetique
      relevant_links << ({ text: "Audit énergétique", url: regional_info[:official_urls][:audit_energetique] }) if regional_info[:official_urls][:audit_energetique]
    end

    # Toujours ajouter le lien principal
    relevant_links << ({ text: "Site officiel #{regional_info[:name]}", url: regional_info[:official_urls][:main] }) if regional_info[:official_urls][:main]

    if relevant_links.any?
      links_section = "\n\n**📋 Sources officielles :**\n"
      relevant_links.each do |link|
        links_section += "- [#{link[:text]}](#{link[:url]})\n"
      end
      content + links_section
    else
      content
    end
  end

  def build_suggested_actions(intent_analysis)
    actions = []
    user_region = @conversation.user_region || @config.dig(:regions, :default)

    case intent_analysis[:category]
    when 'isolation', 'chauffage', 'renovation_generale', 'energie_renouvelable'
      # Actions principales pour les demandes de primes
      actions << ({
        type: 'simulator',
        label: '🎯 Simuler mes primes',
        url: "/simulation/#{user_region}/primes",
        primary: true,
        description: 'Calculez le montant des primes auxquelles vous avez droit'
      })
      actions << ({
        type: 'simulator',
        label: '🏦 Découvrir les prêts à 0%',
        url: "/simulation/#{user_region}/prets",
        primary: false,
        description: 'Prêts verts et financements avantageux'
      })
      actions << ({
        type: 'redirect',
        label: '🚀 Accompagnement Ren0vate',
        url: build_renovate_url,
        primary: false,
        description: 'Gestion complète de A à Z par des experts'
      })

    when 'prets', 'financement'
      # Actions pour les demandes de financement
      actions << ({
        type: 'simulator',
        label: '🏦 Prêts à taux 0%',
        url: "/simulation/#{user_region}/prets",
        primary: true,
        description: 'Découvrez tous les prêts disponibles'
      })
      actions << ({
        type: 'simulator',
        label: '💰 Calculer mes primes',
        url: "/simulation/#{user_region}/primes",
        primary: false,
        description: 'Cumulez primes et prêts pour financer votre projet'
      })
      actions << ({
        type: 'redirect',
        label: '🚀 Solution Ren0vate complète',
        url: build_renovate_url,
        primary: false,
        description: 'Primes + Prêts + Accompagnement'
      })

    when 'monuments', 'patrimoine'
      # Actions spécifiques pour le patrimoine
      actions << ({
        type: 'simulator',
        label: '🏛️ Primes patrimoine',
        url: "/simulation/#{user_region}/primes",
        primary: true,
        description: 'Primes Monuments et Sites, Petit Patrimoine'
      })
      actions << ({
        type: 'redirect',
        label: '📞 Experts patrimoine',
        url: build_renovate_url,
        primary: false,
        description: 'Accompagnement spécialisé bâtiments classés'
      })

    when 'communale'
      # Actions pour primes communales
      actions << ({
        type: 'simulator',
        label: '🏘️ Primes de ma commune',
        url: "/simulation/#{user_region}/primes",
        primary: true,
        description: 'Découvrez les primes communales disponibles'
      })
      actions << ({
        type: 'redirect',
        label: '💬 Assistance personnalisée',
        url: build_renovate_url,
        primary: false,
        description: 'Aide à identifier toutes les primes cumulables'
      })

    when 'information_generale'
      actions << ({
        type: 'internal',
        label: 'ℹ️ À propos de Primes Services',
        url: '/about',
        primary: false,
        description: 'Notre mission et notre équipe'
      })
      actions << ({
        type: 'simulator',
        label: '📊 Simuler mes primes',
        url: "/simulation/#{user_region}/primes",
        primary: true,
        description: 'Estimez vos aides financières'
      })
    end

    # Action universelle : contact expert
    actions << ({
      type: 'contact',
      label: '👨‍💼 Parler à un expert',
      url: 'mailto:equipe@primes-services.be',
      primary: false,
      description: 'Assistance personnalisée par email'
    })

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

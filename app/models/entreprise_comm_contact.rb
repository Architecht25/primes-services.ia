# Modèle spécialisé pour les contacts Entreprises Commerciales (non-immobilières)
class EntrepriseCommContact < ContactSubmission
  # Validations spécifiques aux entreprises commerciales
  validates :business_activity, inclusion: {
    in: %w[retail services manufacturing hospitality agriculture technology consulting healthcare],
    allow_blank: true
  }
  validates :investment_region, inclusion: {
    in: %w[wallonie flandre bruxelles belgique europe international],
    allow_blank: true
  }
  validates :project_scale, inclusion: {
    in: %w[local regional national european international],
    allow_blank: true
  }
  validates :timeline, inclusion: {
    in: %w[immediate court_terme moyen_terme long_terme],
    allow_blank: true
  }
  validates :estimated_budget,
    numericality: { greater_than: 0 },
    allow_blank: true
  validates :target_market, inclusion: {
    in: %w[b2b b2c b2g marketplace local national export],
    allow_blank: true
  }
  validates :company_size, inclusion: {
    in: %w[startup pme eti grande_entreprise],
    allow_blank: true
  }

  # Méthodes spécifiques aux entreprises commerciales
  def investment_category
    return 'non_specifie' unless estimated_budget

    case estimated_budget
    when 0..25_000
      'micro_investissement'
    when 25_001..100_000
      'petit_investissement'
    when 100_001..500_000
      'investissement_moyen'
    when 500_001..2_000_000
      'gros_investissement'
    else
      'tres_gros_investissement'
    end
  end

  def requires_innovation_support?
    business_activity == 'technology' ||
    %w[national international].include?(project_scale) ||
    estimated_budget.to_i > 500_000
  end

  def eligible_for_export_aid?
    %w[national international europe].include?(project_scale) ||
    target_market == 'export'
  end

  def suggested_subsidies
    subsidies = []

    # Aides selon l'activité commerciale
    case business_activity
    when 'retail'
      subsidies << 'Prime commerce local'
      subsidies << 'Aide digitalisation commerce'
      subsidies << 'Subside vitrine commerciale'
    when 'services'
      subsidies << 'Prime services aux entreprises'
      subsidies << 'Aide innovation services'
      subsidies << 'Crédit professionnel services'
    when 'manufacturing'
      subsidies << 'Prime industrie 4.0'
      subsidies << 'Aide modernisation industrielle'
      subsidies << 'Subside équipement production'
    when 'hospitality'
      subsidies << 'Prime secteur HORECA'
      subsidies << 'Aide tourisme'
      subsidies << 'Subside modernisation hôtellerie'
    when 'agriculture'
      subsidies << 'Prime agricole modernisation'
      subsidies << 'Aide diversification agricole'
      subsidies << 'Subside bio et durable'
    when 'technology'
      subsidies << 'Prime innovation technologique'
      subsidies << 'Aide startup tech'
      subsidies << 'Crédit R&D'
    when 'consulting'
      subsidies << 'Prime conseil aux entreprises'
      subsidies << 'Aide formation consulting'
    when 'healthcare'
      subsidies << 'Prime secteur santé'
      subsidies << 'Aide équipement médical'
      subsidies << 'Subside innovation santé'
    end

    # Aides selon la région
    case investment_region
    when 'wallonie'
      subsidies << 'Chèques-entreprises Wallonie'
      subsidies << 'Win (Wallonie Investissement)'
      subsidies << 'SOWAER aide énergétique'
      subsidies << 'Formation Forem entreprise'
    when 'flandre'
      subsidies << 'Vlaamse ondernemingspremies'
      subsidies << 'VLAIO steun innovatie'
      subsidies << 'PMV investeringen'
    when 'bruxelles'
      subsidies << 'Impulse.brussels'
      subsidies << 'Finance.brussels'
      subsidies << '1819.brussels accompagnement'
    when 'europe'
      subsidies << 'Horizon Europe'
      subsidies << 'COSME programme'
      subsidies << 'Fonds FEDER'
    when 'international'
      subsidies << 'AWEX international'
      subsidies << 'Hub.brussels export'
      subsidies << 'Flanders Investment & Trade'
    end

    # Aides selon la taille d'entreprise
    case company_size
    when 'startup'
      subsidies << 'Bourse startups'
      subsidies << 'Capital-risque public'
      subsidies << 'Incubateurs et accélérateurs'
    when 'pme'
      subsidies << 'Prime PME innovation'
      subsidies << 'Crédit PME'
      subsidies << 'Garantie PME'
    when 'eti', 'grande_entreprise'
      subsidies << 'Aide grandes entreprises'
      subsidies << 'Investissement industriel'
    end

    # Aides spécifiques selon le marché cible
    case target_market
    when 'export'
      subsidies << 'Prime à l\'exportation'
      subsidies << 'Missions commerciales'
      subsidies << 'Aide prospection internationale'
    when 'b2g'
      subsidies << 'Marchés publics formation'
      subsidies << 'Aide soumissions publiques'
    end

    # Innovation et R&D
    if requires_innovation_support?
      subsidies << 'Crédit d\'impôt R&D'
      subsidies << 'Brevet + innovation'
      subsidies << 'Pôles de compétitivité'
    end

    # Transition énergétique (tous secteurs)
    subsidies << 'Prime transition énergétique'
    subsidies << 'Audit énergétique entreprise'
    subsidies << 'Investissement vert entreprise'

    # Digitalisation (tous secteurs)
    subsidies << 'Chèque digitalisation'
    subsidies << 'Prime transformation digitale'
    subsidies << 'Cybersécurité entreprise'

    subsidies.uniq
  end

  def business_complexity_score
    # Score de 1 à 10 selon la complexité business
    score = 1 # Base entreprise commerciale

    score += 1 if %w[national international].include?(project_scale)
    score += 1 if business_activity == 'technology'
    score += 1 if estimated_budget.to_i > 500_000
    score += 1 if company_size == 'grande_entreprise'
    score += 1 if target_market == 'export'
    score += 2 if requires_innovation_support?
    score += 1 if investment_region == 'international'

    [score, 10].min
  end

  def requires_specialized_expert?
    business_complexity_score >= 6
  end

  def sector_specific_requirements
    requirements = []

    case business_activity
    when 'retail'
      requirements << 'Autorisation commerciale'
      requirements << 'Assurance responsabilité civile'
    when 'manufacturing'
      requirements << 'Permis d\'exploiter'
      requirements << 'Normes environnementales'
      requirements << 'Certification qualité'
    when 'hospitality'
      requirements << 'Licence HORECA'
      requirements << 'Normes sanitaires'
    when 'healthcare'
      requirements << 'Agrément santé'
      requirements << 'Normes médicales'
    when 'technology'
      requirements << 'Protection intellectuelle'
      requirements << 'Normes cybersécurité'
    end

    if eligible_for_export_aid?
      requirements << 'Certification export'
      requirements << 'Assurance crédit export'
    end

    requirements
  end

  def generate_personalized_message
    message_parts = []
    message_parts << "Bonjour,"
    message_parts << ""

    if business_activity.present? && company_size.present?
      activity_labels = {
        'retail' => 'commerce',
        'services' => 'services aux entreprises',
        'manufacturing' => 'industrie/production',
        'hospitality' => 'HORECA',
        'agriculture' => 'agriculture',
        'technology' => 'technologie',
        'consulting' => 'conseil',
        'healthcare' => 'secteur santé'
      }

      size_labels = {
        'startup' => 'startup',
        'pme' => 'PME',
        'eti' => 'ETI',
        'grande_entreprise' => 'grande entreprise'
      }

      message_parts << "Merci pour votre demande concernant votre #{size_labels[company_size]} "
      message_parts << "dans le secteur #{activity_labels[business_activity]} (région #{investment_region.humanize})."
    end

    if estimated_budget.present?
      message_parts << ""
      message_parts << "Pour votre investissement de #{estimated_budget.to_i}€, voici les principales aides :"
      suggested_subsidies.take(6).each { |subsidy| message_parts << "• #{subsidy}" }
    end

    if requires_specialized_expert?
      message_parts << ""
      message_parts << "🚀 Ce projet nécessite un accompagnement expert spécialisé."
      message_parts << "Nos consultants sectoriels vous contacteront pour :"
      message_parts << "• Optimisation du plan de financement"
      message_parts << "• Accompagnement réglementaire"
      message_parts << "• Stratégie de développement"
    end

    sector_reqs = sector_specific_requirements
    if sector_reqs.any?
      message_parts << ""
      message_parts << "📋 Prérequis sectoriels :"
      sector_reqs.take(3).each { |req| message_parts << "• #{req}" }
    end

    if eligible_for_export_aid?
      message_parts << ""
      message_parts << "🌍 Votre projet d'internationalisation peut bénéficier d'aides spécifiques à l'export."
    end

    message_parts << ""
    message_parts << "Un consultant expert vous recontacte sous 24h pour un diagnostic personnalisé."
    message_parts << ""
    message_parts << "Cordialement,"
    message_parts << "L'équipe Primes Services - Division Entreprises & Innovation"

    message_parts.join("\n")
  end

  def financing_needs_analysis
    needs = []

    case investment_category
    when 'micro_investissement', 'petit_investissement'
      needs << 'Microcrédit professionnel'
      needs << 'Crowdfunding'
    when 'investissement_moyen'
      needs << 'Crédit bancaire PME'
      needs << 'Business angels'
    when 'gros_investissement', 'tres_gros_investissement'
      needs << 'Financement structuré'
      needs << 'Capital investissement'
      needs << 'Obligations convertibles'
    end

    if requires_innovation_support?
      needs << 'Fonds innovation'
      needs << 'Capital-risque tech'
    end

    needs
  end

  def digital_transformation_level
    return 'basique' unless business_activity

    tech_intensive = %w[technology services consulting]
    traditional = %w[retail manufacturing hospitality agriculture]

    if tech_intensive.include?(business_activity)
      'avance'
    elsif traditional.include?(business_activity)
      company_size == 'startup' ? 'intermediaire' : 'basique'
    else
      'intermediaire'
    end
  end

  # Méthode pour préparer les données pour les partenaires business
  def business_partner_redirect_params
    {
      source: 'primes_services',
      profile: 'entreprise_comm',
      activity: business_activity,
      region: investment_region,
      scale: project_scale,
      budget: estimated_budget,
      market: target_market,
      size: company_size,
      timeline: timeline,
      complexity: business_complexity_score,
      digital_level: digital_transformation_level,
      export_eligible: eligible_for_export_aid?,
      contact_id: id
    }.compact
  end

  def innovation_potential_score
    score = 1

    score += 2 if business_activity == 'technology'
    score += 1 if company_size == 'startup'
    score += 1 if requires_innovation_support?
    score += 1 if %w[national international].include?(project_scale)
    score += 1 if estimated_budget.to_i > 100_000

    [score, 10].min
  end

  def sustainability_opportunities
    opportunities = []

    opportunities << 'Certification B-Corp' if company_size != 'startup'
    opportunities << 'Label entreprise responsable'
    opportunities << 'Transition énergétique'
    opportunities << 'Économie circulaire'

    if business_activity == 'manufacturing'
      opportunities << 'Industrie verte'
      opportunities << 'Décarbonation production'
    end

    opportunities
  end
end

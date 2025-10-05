# Modèle spécialisé pour les contacts Entreprises Immobilières
class EntrepriseImmoContact < ContactSubmission
  # Validations spécifiques aux entreprises immobilières
  validates :business_activity, inclusion: { 
    in: %w[promotion construction renovation gestion syndic marchand], 
    allow_blank: true 
  }
  validates :investment_region, inclusion: { 
    in: %w[wallonie flandre bruxelles international], 
    allow_blank: true 
  }
  validates :project_scale, inclusion: { 
    in: %w[unitaire petit_ensemble grand_ensemble quartier], 
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
    in: %w[social prive mixte luxe etudiant senior], 
    allow_blank: true 
  }

  # Méthodes spécifiques aux entreprises immobilières
  def investment_category
    return 'non_specifie' unless estimated_budget
    
    case estimated_budget
    when 0..100_000
      'petit_investissement'
    when 100_001..500_000
      'investissement_moyen'
    when 500_001..2_000_000
      'gros_investissement'
    else
      'tres_gros_investissement'
    end
  end

  def requires_environmental_certification?
    %w[grand_ensemble quartier].include?(project_scale) || 
    estimated_budget.to_i > 1_000_000
  end

  def eligible_for_developer_incentives?
    business_activity == 'promotion' && 
    %w[social mixte].include?(target_market)
  end

  def suggested_subsidies
    subsidies = []
    
    # Aides selon l'activité
    case business_activity
    when 'promotion'
      subsidies << 'Aide aux promoteurs sociaux'
      subsidies << 'Subsides logement social'
      subsidies << 'Prime construction durable'
    when 'construction'
      subsidies << 'Prime entrepreneur construction'
      subsidies << 'Aide innovation construction'
      subsidies << 'Crédit professionnel vert'
    when 'renovation'
      subsidies << 'Prime professionnelle rénovation'
      subsidies << 'Aide rénovation immeuble de rapport'
      subsidies << 'Subside valorisation patrimoine'
    when 'gestion'
      subsidies << 'Prime gestionnaire immobilier'
      subsidies << 'Aide professionnalisation gestion'
    when 'syndic'
      subsidies << 'Prime syndic professionnel'
      subsidies << 'Formation syndic agréé'
    when 'marchand'
      subsidies << 'Prime marchand de biens'
      subsidies << 'Aide négociant immobilier'
    end

    # Aides selon la région d'investissement
    case investment_region
    when 'wallonie'
      subsidies << 'Aide investissement Wallonie'
      subsidies << 'SOWAER - Société wallonne de l\'énergie'
      subsidies << 'Prime rénovation énergétique pro'
      subsidies << 'Crédit logement social Wallonie' if eligible_for_developer_incentives?
    when 'flandre'
      subsidies << 'Vlaamse investeringspremie'
      subsidies << 'Sociale huisvestingsmaatschappij steun'
      subsidies << 'Renovatiepremie ondernemers'
    when 'bruxelles'
      subsidies << 'Aide investissement Bruxelles'
      subsidies << 'SLRB - Société du logement'
      subsidies << 'Prime rénovation professionnelle'
      subsidies << 'Fonds du logement Bruxelles' if eligible_for_developer_incentives?
    when 'international'
      subsidies << 'Aide export immobilier'
      subsidies << 'AWEX - Agence wallonne export'
    end

    # Aides selon l'échelle du projet
    case project_scale
    when 'grand_ensemble', 'quartier'
      subsidies << 'Aide grands projets immobiliers'
      subsidies << 'Subside aménagement urbain'
      subsidies << 'Prime développement durable'
    end

    # Aides selon le marché cible
    case target_market
    when 'social'
      subsidies << 'Crédit social construction'
      subsidies << 'Aide logement social'
      subsidies << 'Subside logement public'
    when 'etudiant'
      subsidies << 'Prime logement étudiant'
      subsidies << 'Aide kotiers'
    when 'senior'
      subsidies << 'Prime logement senior'
      subsidies << 'Aide maison de repos'
    end

    # Certifications environnementales
    if requires_environmental_certification?
      subsidies << 'Certification BREEAM'
      subsidies << 'Label passif professionnel'
      subsidies << 'Prime construction écologique'
    end

    subsidies.uniq
  end

  def business_complexity_score
    # Score de 1 à 10 selon la complexité business
    score = 2 # Base entreprise
    
    score += 1 if %w[grand_ensemble quartier].include?(project_scale)
    score += 1 if business_activity == 'promotion'
    score += 1 if estimated_budget.to_i > 1_000_000
    score += 1 if investment_region == 'international'
    score += 1 if target_market == 'social'
    score += 2 if requires_environmental_certification?
    
    [score, 10].min
  end

  def requires_business_expert?
    business_complexity_score >= 7
  end

  def legal_framework_requirements
    requirements = []
    
    case business_activity
    when 'promotion'
      requirements << 'Garantie promoteur'
      requirements << 'Assurance dommages-ouvrage'
      requirements << 'Permis d\'urbanisme'
    when 'construction'
      requirements << 'Agrément construction'
      requirements << 'Assurance responsabilité décennale'
    when 'syndic'
      requirements << 'Agrément syndic'
      requirements << 'Assurance responsabilité civile professionnelle'
    when 'gestion'
      requirements << 'Carte professionnelle immobilière'
      requirements << 'Compte clients séparé'
    end

    if project_scale == 'quartier'
      requirements << 'Étude d\'impact environnemental'
      requirements << 'Concertation publique'
    end

    requirements
  end

  def generate_personalized_message
    message_parts = []
    message_parts << "Bonjour,"
    message_parts << ""
    
    if business_activity.present?
      activity_label = {
        'promotion' => 'promotion immobilière',
        'construction' => 'construction',
        'renovation' => 'rénovation',
        'gestion' => 'gestion immobilière',
        'syndic' => 'syndic professionnel',
        'marchand' => 'marchand de biens'
      }
      
      message_parts << "Merci pour votre demande concernant votre activité de #{activity_label[business_activity]}"
      message_parts << "en région #{investment_region.humanize}."
    end
    
    if project_scale.present? || estimated_budget.present?
      message_parts << ""
      message_parts << "Votre projet (#{project_scale&.humanize&.downcase}, budget: #{estimated_budget&.to_i}&€) peut bénéficier de :"
      suggested_subsidies.take(5).each { |subsidy| message_parts << "• #{subsidy}" }
    end
    
    if requires_business_expert?
      message_parts << ""
      message_parts << "🏢 Ce projet nécessite un accompagnement business spécialisé."
      message_parts << "Nos experts en investissement immobilier vous contacteront pour :"
      message_parts << "• Optimisation fiscale et financière"
      message_parts << "• Montage juridique optimal"
      message_parts << "• Maximisation des aides publiques"
    end
    
    legal_reqs = legal_framework_requirements
    if legal_reqs.any?
      message_parts << ""
      message_parts << "📋 Cadre légal requis :"
      legal_reqs.take(3).each { |req| message_parts << "• #{req}" }
    end
    
    message_parts << ""
    message_parts << "Un expert business vous recontacte sous 24h pour un audit personnalisé."
    message_parts << ""
    message_parts << "Cordialement,"
    message_parts << "L'équipe Primes Services - Division Entreprises Immobilières"
    
    message_parts.join("\n")
  end

  def fiscal_optimization_potential
    return 'faible' unless estimated_budget
    
    case investment_category
    when 'petit_investissement'
      'faible'
    when 'investissement_moyen'
      eligible_for_developer_incentives? ? 'moyen' : 'faible'
    when 'gros_investissement', 'tres_gros_investissement'
      'eleve'
    end
  end

  # Méthode pour préparer les données pour Ren0vate Pro
  def renovate_pro_redirect_params
    {
      source: 'primes_services',
      profile: 'entreprise_immo',
      activity: business_activity,
      region: investment_region,
      scale: project_scale,
      budget: estimated_budget,
      market: target_market,
      timeline: timeline,
      complexity: business_complexity_score,
      fiscal_potential: fiscal_optimization_potential,
      contact_id: id
    }.compact
  end

  def partnership_opportunities
    opportunities = []
    
    if business_activity == 'promotion' && target_market == 'social'
      opportunities << 'Partenariat société logement social'
    end
    
    if project_scale == 'quartier'
      opportunities << 'Partenariat commune'
      opportunities << 'Fonds européens FEDER'
    end
    
    if requires_environmental_certification?
      opportunities << 'Partenariat bureau études environnement'
      opportunities << 'Certification écologique'
    end
    
    opportunities
  end
end
# Modèle spécialisé pour les contacts Particuliers
class ParticulierContact < ContactSubmission
  # Validations spécifiques aux particuliers
  validates :property_type, inclusion: { 
    in: %w[maison appartement], 
    allow_blank: true 
  }
  validates :construction_year, 
    numericality: { 
      greater_than: 1800, 
      less_than_or_equal_to: Date.current.year 
    }, 
    allow_blank: true
  validates :work_type, inclusion: { 
    in: %w[isolation chauffage renovation_globale photovoltaique ventilation], 
    allow_blank: true 
  }
  validates :estimated_budget, 
    numericality: { greater_than: 0 }, 
    allow_blank: true
  validates :realization_deadline, inclusion: { 
    in: %w[urgent cette_annee flexible], 
    allow_blank: true 
  }

  # Méthodes spécifiques aux particuliers
  def property_age
    return nil unless construction_year
    Date.current.year - construction_year
  end

  def is_old_property?
    property_age && property_age > 30
  end

  def budget_category
    return 'non_specifie' unless estimated_budget
    
    case estimated_budget
    when 0..5000
      'petit_budget'
    when 5001..15000
      'budget_moyen'
    when 15001..50000
      'gros_budget'
    else
      'budget_important'
    end
  end

  def eligible_for_renovation_pack?
    # Logique pour déterminer l'éligibilité au Rénopack
    work_type == 'renovation_globale' && is_old_property?
  end

  def suggested_subsidies
    subsidies = []
    
    case work_type
    when 'isolation'
      subsidies << 'Prime isolation toiture'
      subsidies << 'Prime isolation murs'
      subsidies << 'Prime isolation sols' if is_old_property?
    when 'chauffage'
      subsidies << 'Prime pompe à chaleur'
      subsidies << 'Prime chaudière à condensation'
      subsidies << 'Prime audit énergétique'
    when 'renovation_globale'
      subsidies << 'Rénopack' if region == 'wallonie'
      subsidies << 'Prime rénovation lourde'
      subsidies << 'Prime audit énergétique'
    when 'photovoltaique'
      subsidies << 'Certificats verts'
      subsidies << 'Prime photovoltaïque communale'
    end

    # Ajout des primes régionales spécifiques
    case region
    when 'wallonie'
      subsidies << 'Prime Habitation Wallonie'
    when 'flandre'
      subsidies << 'Vlaamse renovatiepremie'
    when 'bruxelles'
      subsidies << 'Prime Renolution'
    end

    subsidies.uniq
  end

  def generate_personalized_message
    message_parts = []
    message_parts << "Bonjour #{name},"
    message_parts << ""
    
    if property_type.present?
      message_parts << "Merci pour votre demande concernant votre #{property_type}"
      message_parts << "construite en #{construction_year}." if construction_year.present?
    end
    
    if work_type.present?
      message_parts << ""
      message_parts << "Pour vos travaux de #{work_type.humanize.downcase}, voici les primes potentielles :"
      suggested_subsidies.each { |subsidy| message_parts << "• #{subsidy}" }
    end
    
    message_parts << ""
    message_parts << "Notre équipe va analyser votre dossier et vous recontacter sous 24h."
    message_parts << ""
    message_parts << "Cordialement,"
    message_parts << "L'équipe Primes Services"
    
    message_parts.join("\n")
  end

  # Méthode pour préparer les données pour Ren0vate
  def renovate_redirect_params
    {
      source: 'primes_services',
      profile: 'particulier',
      region: region,
      property_type: property_type,
      work_type: work_type,
      budget: estimated_budget,
      urgency: realization_deadline,
      construction_year: construction_year,
      contact_id: id
    }.compact
  end
end
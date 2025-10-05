# Modèle spécialisé pour les contacts ACP (Associations de Copropriétaires)
class AcpContact < ContactSubmission
  # Validations spécifiques aux ACP
  validates :number_of_units, 
    numericality: { greater_than: 1, less_than: 1000 }, 
    allow_blank: true
  validates :building_type, inclusion: { 
    in: %w[residentiel mixte commercial], 
    allow_blank: true 
  }
  validates :building_work_type, inclusion: { 
    in: %w[facade toiture chauffage isolation ascenseur communs], 
    allow_blank: true 
  }
  validates :voted_budget, 
    numericality: { greater_than: 0 }, 
    allow_blank: true
  validates :work_urgency, inclusion: { 
    in: %w[urgent planifie etude], 
    allow_blank: true 
  }

  # Méthodes spécifiques aux ACP
  def building_size_category
    return 'non_specifie' unless number_of_units
    
    case number_of_units
    when 1..4
      'petite_copropriete'
    when 5..20
      'copropriete_moyenne'
    when 21..50
      'grande_copropriete'
    else
      'tres_grande_copropriete'
    end
  end

  def estimated_cost_per_unit
    return nil unless voted_budget && number_of_units && number_of_units > 0
    voted_budget / number_of_units
  end

  def eligible_for_group_subsidies?
    number_of_units && number_of_units >= 5
  end

  def suggested_subsidies
    subsidies = []
    
    case building_work_type
    when 'facade'
      subsidies << 'Prime rénovation façade copropriété'
      subsidies << 'Prime embellissement façade'
    when 'toiture'
      subsidies << 'Prime rénovation toiture collective'
      subsidies << 'Prime isolation toiture copropriété'
    when 'chauffage'
      subsidies << 'Prime chauffage collectif'
      subsidies << 'Prime pompe à chaleur collective'
      subsidies << 'Prime audit énergétique immeuble'
    when 'isolation'
      subsidies << 'Prime isolation collective'
      subsidies << 'Prime rénovation énergétique immeuble'
    when 'ascenseur'
      subsidies << 'Prime accessibilité PMR'
      subsidies << 'Prime modernisation ascenseur'
    when 'communs'
      subsidies << 'Prime rénovation parties communes'
      subsidies << 'Prime embellissement copropriété'
    end

    # Primes spécifiques selon la région
    case region
    when 'wallonie'
      subsidies << 'Prime copropriété Wallonie'
      subsidies << 'Aide SPW Logement' if eligible_for_group_subsidies?
    when 'flandre'
      subsidies << 'Vlaamse woningrenovatiepremie'
      subsidies << 'VMM collectieve premie'
    when 'bruxelles'
      subsidies << 'Prime Renolution copropriété'
      subsidies << 'Aide BatEx collective'
    end

    # Primes spéciales pour grandes copropriétés
    if building_size_category == 'grande_copropriete' || building_size_category == 'tres_grande_copropriete'
      subsidies << 'Prime rénovation lourde collective'
      subsidies << 'Subsides UREBA' if region == 'bruxelles'
    end

    subsidies.uniq
  end

  def administrative_complexity_score
    # Score de 1 à 10 selon la complexité administrative
    score = 3 # Base
    
    score += 1 if number_of_units && number_of_units > 20
    score += 1 if building_work_type == 'chauffage'
    score += 1 if work_urgency == 'urgent'
    score += 1 if building_type == 'mixte'
    score += 2 if voted_budget && voted_budget > 100000
    
    [score, 10].min
  end

  def requires_expert_assistance?
    administrative_complexity_score >= 6
  end

  def generate_personalized_message
    message_parts = []
    message_parts << "Bonjour,"
    message_parts << ""
    
    if number_of_units.present?
      message_parts << "Merci pour votre demande concernant votre copropriété de #{number_of_units} logements"
      message_parts << "en région #{region.humanize}."
    end
    
    if building_work_type.present?
      message_parts << ""
      message_parts << "Pour vos travaux de #{building_work_type.humanize.downcase}, voici les aides disponibles :"
      suggested_subsidies.each { |subsidy| message_parts << "• #{subsidy}" }
    end
    
    if requires_expert_assistance?
      message_parts << ""
      message_parts << "⚠️ Ce dossier nécessite un accompagnement expert en raison de sa complexité."
      message_parts << "Nos spécialistes copropriété vous contacteront pour un accompagnement personnalisé."
    end
    
    message_parts << ""
    message_parts << "Nous analysons votre demande et revenons vers vous sous 48h."
    message_parts << ""
    message_parts << "Cordialement,"
    message_parts << "L'équipe Primes Services - Spécialistes Copropriétés"
    
    message_parts.join("\n")
  end

  def syndic_contact_info
    return {} unless syndic_contact.present?
    
    # Parsing basique des infos syndic (nom, email, téléphone)
    info = {}
    if syndic_contact.include?('@')
      info[:email] = syndic_contact.match(/\S+@\S+\.\S+/)&.to_s
    end
    if syndic_contact.match?(/[\d\s\+\-\(\)]{10,}/)
      info[:phone] = syndic_contact.scan(/[\d\s\+\-\(\)]{10,}/).first
    end
    
    info[:name] = syndic_contact.gsub(info[:email] || '', '').gsub(info[:phone] || '', '').strip
    info.compact
  end

  # Méthode pour préparer les données pour Ren0vate
  def renovate_redirect_params
    {
      source: 'primes_services',
      profile: 'copropriete',
      region: region,
      building_type: building_type,
      work_type: building_work_type,
      units: number_of_units,
      budget: voted_budget,
      urgency: work_urgency,
      complexity: administrative_complexity_score,
      contact_id: id
    }.compact
  end
end
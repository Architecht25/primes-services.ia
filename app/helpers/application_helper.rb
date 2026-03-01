module ApplicationHelper
  # ========================================
  # HELPERS SEO AVANCÉS
  # ========================================

  # Génère un titre SEO optimisé avec structure hiérarchique
  def page_title(title = nil, region: nil)
    parts = []
    parts << title if title.present?
    parts << region_name(region) if region.present?
    parts << "Primes Services IA"
    
    parts.join(' | ')
  end

  # Meta description optimisée (150-160 caractères idéalement)
  def page_description(description = nil, region: nil)
    return description if description.present?

    if region.present?
      "Découvrez toutes les primes et subsides en #{region_name(region)}. Assistant IA expert, calculs instantanés, accompagnement personnalisé. Prêts à 0%, primes régionales et communales."
    else
      "Assistant IA spécialisé en primes et subsides belges. Primes énergétiques, rénovation, patrimoine. Wallonie, Flandre, Bruxelles. Calculs instantanés et accompagnement expert."
    end
  end

  # Mots-clés SEO contextuels par région
  def page_keywords(region: nil, additional: [])
    base = ['primes belges', 'subsides belgique', 'primes énergétiques', 'primes rénovation', 
            'assistant IA', 'prêts 0%', 'aide publique', 'primes isolation', 'primes chauffage']
    
    if region.present?
      base += region_keywords(region)
    end
    
    (base + additional).uniq.join(', ')
  end

  # Génère des breadcrumbs JSON-LD pour le SEO
  def breadcrumbs_json_ld(items)
    schema = {
      "@context" => "https://schema.org",
      "@type" => "BreadcrumbList",
      "itemListElement" => items.each_with_index.map do |(name, url), index|
        {
          "@type" => "ListItem",
          "position" => index + 1,
          "name" => name,
          "item" => url ? "#{request.base_url}#{url}" : nil
        }.compact
      end
    }
    
    content_tag(:script, schema.to_json.html_safe, type: 'application/ld+json')
  end

  # FAQPage Schema pour SEO enrichi
  def faq_schema_json_ld(faqs)
    schema = {
      "@context" => "https://schema.org",
      "@type" => "FAQPage",
      "mainEntity" => faqs.map do |faq|
        {
          "@type" => "Question",
          "name" => faq[:question],
          "acceptedAnswer" => {
            "@type" => "Answer",
            "text" => faq[:answer]
          }
        }
      end
    }
    
    content_tag(:script, schema.to_json.html_safe, type: 'application/ld+json')
  end

  # LocalBusiness Schema enrichi par région
  def local_business_schema_json_ld(region: nil)
    base_schema = {
      "@context" => "https://schema.org",
      "@type" => "LocalBusiness",
      "name" => region ? "Primes Services IA - #{region_name(region)}" : "Primes Services IA",
      "description" => page_description(nil, region: region),
      "url" => request.original_url,
      "logo" => "#{request.base_url}/icon.png",
      "image" => "#{request.base_url}/icon.png",
      "address" => {
        "@type" => "PostalAddress",
        "addressCountry" => "BE"
      },
      "areaServed" => region ? region_area_served(region) : ["Belgique", "Wallonie", "Flandre", "Bruxelles-Capitale"],
      "serviceType" => "Conseil en subsides et primes",
      "priceRange" => "Gratuit"
    }

    if region
      base_schema["address"]["addressRegion"] = region_name(region)
      base_schema["geo"] = region_coordinates(region)
    end

    content_tag(:script, base_schema.to_json.html_safe, type: 'application/ld+json')
  end

  # Organization Schema (pour la page d'accueil)
  def organization_schema_json_ld
    schema = {
      "@context" => "https://schema.org",
      "@type" => "Organization",
      "name" => "Primes Services IA",
      "url" => request.base_url,
      "logo" => "#{request.base_url}/icon.png",
      "description" => "Assistant IA spécialisé en primes et subsides belges",
      "areaServed" => "Belgique",
      "knowsAbout" => ["Primes énergétiques", "Subsides belges", "Primes rénovation", "Prêts à taux 0%", "Primes patrimoine"],
      "sameAs" => [
        # Ajoutez vos réseaux sociaux ici
        # "https://facebook.com/primes-services",
        # "https://twitter.com/primes_services",
        # "https://linkedin.com/company/primes-services"
      ]
    }

    content_tag(:script, schema.to_json.html_safe, type: 'application/ld+json')
  end

  # ========================================
  # HELPERS RÉGIONAUX PRIVÉS
  # ========================================

  private

  def region_name(region_key)
    regions = {
      'wallonie' => 'Wallonie',
      'flandre' => 'Flandre',
      'bruxelles' => 'Bruxelles-Capitale'
    }
    regions[region_key.to_s] || region_key.to_s.titleize
  end

  def region_keywords(region)
    case region.to_s
    when 'wallonie'
      ['primes wallonie', 'subsides wallonie', 'rénopack', 'prime habitation wallonie', 
       'isolation wallonie', 'chauffage wallonie', 'primes communales wallonie']
    when 'flandre'
      ['primes flandre', 'subsides vlaanderen', 'vlaamse premie', 'renovatiepremie', 
       'energielening', 'isolatie premie', 'verwarmingspremie']
    when 'bruxelles'
      ['primes bruxelles', 'subsides bruxelles', 'renolution', 'prime energie bruxelles', 
       'isolation bruxelles', 'primes communales bruxelles', 'rénovation bruxelles']
    else
      []
    end
  end

  def region_area_served(region)
    case region.to_s
    when 'wallonie'
      ["Wallonie", "Région wallonne", "Liège", "Charleroi", "Namur", "Mons"]
    when 'flandre'
      ["Flandre", "Vlaanderen", "Anvers", "Gand", "Bruges", "Louvain"]
    when 'bruxelles'
      ["Bruxelles-Capitale", "Bruxelles", "Ixelles", "Uccle", "Schaerbeek"]
    else
      []
    end
  end

  def region_coordinates(region)
    coords = {
      'wallonie' => { "latitude" => 50.4674, "longitude" => 4.8720 },
      'flandre' => { "latitude" => 51.0543, "longitude" => 3.7174 },
      'bruxelles' => { "latitude" => 50.8503, "longitude" => 4.3517 }
    }
    
    coord = coords[region.to_s]
    return nil unless coord

    {
      "@type" => "GeoCoordinates",
      "latitude" => coord["latitude"],
      "longitude" => coord["longitude"]
    }
  end
end


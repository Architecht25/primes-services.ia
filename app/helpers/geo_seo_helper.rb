module GeoSeoHelper
  # Helper pour l'optimisation SEO géographique/local

  # Configuration des régions belges pour le Local SEO
  REGIONS_CONFIG = {
    wallonie: {
      name: "Wallonie",
      name_local: "Région wallonne",
      language: "fr",
      capital: "Namur",
      major_cities: ["Liège", "Charleroi", "Namur", "Mons", "Tournai", "Verviers", "La Louvière"],
      postal_codes: (1300..1499).to_a + (4000..7999).to_a,
      authority: "Service Public de Wallonie",
      contact_number: "1718",
      website: "https://energie.wallonie.be",
      coordinates: { lat: 50.4674, lng: 4.8720 },
      area_served: "Wallonie, Belgique",
      programs: ["Prime Habitation", "Isolation+", "Chauffage+", "Rénopack"]
    },
    flandre: {
      name: "Flandre",
      name_local: "Vlaams Gewest",
      language: "nl",
      capital: "Bruxelles", # Administrative
      major_cities: ["Anvers", "Gand", "Bruges", "Louvain", "Malines", "Ostende", "Courtrai"],
      postal_codes: (1500..3999).to_a + (8000..9999).to_a,
      authority: "Vlaams Energieagentschap",
      contact_number: "1700",
      website: "https://vlaanderen.be/premies",
      coordinates: { lat: 51.0543, lng: 3.7174 },
      area_served: "Vlaanderen, België",
      programs: ["Mijn VerbouwPremie", "Energielening", "Vlaamse renovatiepremie"]
    },
    bruxelles: {
      name: "Bruxelles-Capitale",
      name_local: "Région de Bruxelles-Capitale",
      language: "fr/nl",
      capital: "Bruxelles",
      major_cities: ["Bruxelles", "Ixelles", "Uccle", "Schaerbeek", "Anderlecht", "Woluwe-Saint-Lambert"],
      postal_codes: (1000..1299).to_a,
      authority: "Bruxelles Environnement",
      contact_number: "02 775 75 75",
      website: "https://environnement.brussels",
      coordinates: { lat: 50.8503, lng: 4.3517 },
      area_served: "Bruxelles-Capitale, Belgique",
      programs: ["Renolution", "Prime Energie", "Prime Isolation"]
    }
  }.freeze

  # Génère un schema LocalBusiness pour une région spécifique
  def region_local_business_schema(region_key)
    region = REGIONS_CONFIG[region_key.to_sym]
    return {} unless region

    schema = {
      "@context": "https://schema.org",
      "@type": "LocalBusiness",
      "name": "Primes Services IA - #{region[:name]}",
      "description": "Assistant IA spécialisé en primes et subsides pour la #{region[:name]}",
      "url": "#{request.base_url}/regions/#{region_key}",
      "image": "#{request.base_url}/icon.png",
      "logo": "#{request.base_url}/icon.png",
      "address": {
        "@type": "PostalAddress",
        "addressRegion": region[:name],
        "addressCountry": "BE"
      },
      "geo": {
        "@type": "GeoCoordinates",
        "latitude": region[:coordinates][:lat],
        "longitude": region[:coordinates][:lng]
      },
      "areaServed": {
        "@type": "State",
        "name": region[:area_served]
      },
      "serviceArea": {
        "@type": "GeoCircle",
        "geoMidpoint": {
          "@type": "GeoCoordinates",
          "latitude": region[:coordinates][:lat],
          "longitude": region[:coordinates][:lng]
        },
        "geoRadius": "100000"
      },
      "contactPoint": {
        "@type": "ContactPoint",
        "telephone": region[:contact_number],
        "contactType": "Service client",
        "areaServed": region[:area_served],
        "availableLanguage": region[:language]
      },
      "knowsAbout": region[:programs],
      "sameAs": [
        region[:website],
        request.base_url
      ]
    }

    raw("<script type='application/ld+json'>#{schema.to_json}</script>")
  end

  # Schema pour les villes principales
  def city_service_schema(city_name, region_key)
    region = REGIONS_CONFIG[region_key.to_sym]
    return {} unless region && region[:major_cities].include?(city_name)

    schema = {
      "@context": "https://schema.org",
      "@type": "Service",
      "name": "Primes et subsides #{city_name}",
      "description": "Assistant IA pour obtenir vos primes à #{city_name}, #{region[:name]}",
      "provider": {
        "@type": "Organization",
        "name": "Primes Services IA",
        "url": request.base_url
      },
      "areaServed": {
        "@type": "City",
        "name": city_name,
        "containedInPlace": {
          "@type": "State",
          "name": region[:name]
        }
      },
      "serviceType": "Conseil en subsides et primes",
      "offers": {
        "@type": "Offer",
        "description": "Accompagnement gratuit pour vos primes à #{city_name}",
        "price": "0",
        "priceCurrency": "EUR"
      }
    }

    raw("<script type='application/ld+json'>#{schema.to_json}</script>")
  end

  # Génère les mots-clés SEO géographiques
  def geo_keywords(region_key, additional_terms = [])
    region = REGIONS_CONFIG[region_key.to_sym]
    return '' unless region

    base_keywords = [
      "primes #{region[:name].downcase}",
      "subsides #{region[:name].downcase}",
      "aide financière #{region[:name].downcase}",
      "primes énergétiques #{region[:name].downcase}"
    ]

    # Ajouter les villes principales
    city_keywords = region[:major_cities].map do |city|
      ["primes #{city.downcase}", "subsides #{city.downcase}"]
    end.flatten

    # Ajouter les programmes spécifiques
    program_keywords = region[:programs].map do |program|
      program.downcase
    end

    all_keywords = (base_keywords + city_keywords + program_keywords + additional_terms).uniq
    all_keywords.join(', ')
  end

  # Génère une meta description géolocalisée
  def geo_meta_description(region_key, page_type = 'general')
    region = REGIONS_CONFIG[region_key.to_sym]
    return '' unless region

    case page_type
    when 'general'
      "Obtenez vos primes et subsides en #{region[:name]} avec notre assistant IA. #{region[:programs].join(', ')}. Accompagnement gratuit et personnalisé."
    when 'contact'
      "Contactez nos experts pour vos primes en #{region[:name]}. Spécialistes des subsides #{region[:name].downcase} depuis 15 ans."
    when 'calculator'
      "Calculez vos primes #{region[:name].downcase} instantanément. #{region[:programs].first} et autres subsides disponibles."
    else
      "Expert en primes #{region[:name].downcase} : assistant IA, calculs gratuits, accompagnement personnalisé."
    end
  end

  # Helper pour les breadcrumbs géographiques
  def geo_breadcrumbs(region_key, city = nil, page_name = nil)
    region = REGIONS_CONFIG[region_key.to_sym]
    return [] unless region

    breadcrumbs = [
      ["Accueil", root_path],
      ["Régions", "/regions"],
      [region[:name], "/regions/#{region_key}"]
    ]

    if city
      breadcrumbs << [city, "/regions/#{region_key}/#{city.parameterize}"]
    end

    if page_name
      breadcrumbs << [page_name, nil]
    end

    breadcrumbs
  end

  # Détecte la région à partir du code postal
  def detect_region_from_postal_code(postal_code)
    return nil unless postal_code.present?

    code = postal_code.to_i

    REGIONS_CONFIG.each do |key, region|
      if region[:postal_codes].include?(code)
        return key.to_s
      end
    end

    nil
  end

  # Génère l'URL canonique géographique
  def geo_canonical_url(region_key, path_suffix = '')
    "#{request.base_url}/regions/#{region_key}#{path_suffix}"
  end
end

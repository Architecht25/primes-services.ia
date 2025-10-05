# Service de géolocalisation pour optimiser les suggestions de primes selon la localisation
class GeolocationService
  class << self
    # Analyser l'adresse pour extraire informations géographiques pertinentes
    def analyze_location(contact)
      return {} unless contact.address.present? || contact.postal_code.present?

      location_data = {
        region: contact.region,
        postal_code: contact.postal_code,
        city: contact.city,
        address: contact.address
      }

      # Enrichir avec des données géographiques spécifiques
      enrich_with_regional_data(location_data)
    end

    # Identifier les spécificités locales qui peuvent affecter les primes
    def get_local_specifics(contact)
      specifics = []

      case contact.region
      when 'wallonie'
        specifics.concat(get_wallonie_specifics(contact))
      when 'flandre'
        specifics.concat(get_flandre_specifics(contact))
      when 'bruxelles'
        specifics.concat(get_bruxelles_specifics(contact))
      end

      # Ajouter spécificités par code postal si disponible
      if contact.postal_code.present?
        specifics.concat(get_postal_code_specifics(contact.postal_code))
      end

      specifics.uniq
    end

    # Identifier les organismes locaux compétents
    def get_local_authorities(contact)
      authorities = {
        regional: get_regional_authorities(contact.region),
        local: get_local_authorities_by_postal_code(contact.postal_code),
        energy: get_energy_providers(contact.region),
        social: get_social_housing_companies(contact.region, contact.postal_code)
      }

      authorities.compact
    end

    # Calculer la distance vers les centres de service
    def calculate_service_distances(contact)
      return {} unless contact.postal_code.present?

      # Points de service par région
      service_points = get_service_points(contact.region)

      distances = {}
      service_points.each do |service, locations|
        distances[service] = find_nearest_location(contact.postal_code, locations)
      end

      distances
    end

    # Recommandations spécifiques à la zone géographique
    def get_geographic_recommendations(contact)
      recommendations = []

      # Recommandations climatiques
      recommendations.concat(get_climate_recommendations(contact.region))

      # Recommandations urbaines vs rurales
      recommendations.concat(get_urban_rural_recommendations(contact))

      # Recommandations selon la typologie locale
      recommendations.concat(get_local_building_recommendations(contact))

      recommendations
    end

    private

    def enrich_with_regional_data(location_data)
      enriched = location_data.dup

      case location_data[:region]
      when 'wallonie'
        enriched.merge!(
          authority: 'SPW Territoire Logement Patrimoine Énergie',
          energy_agency: 'SPW Énergie',
          main_programs: ['Habitation+', 'Isolation+', 'Chauffage+'],
          contact_center: '1718 (numéro vert)',
          website: 'energie.wallonie.be'
        )
      when 'flandre'
        enriched.merge!(
          authority: 'Vlaams Energieagentschap (VEA)',
          energy_agency: 'VEA',
          main_programs: ['Mijn VerbouwPremie', 'Energielening'],
          contact_center: '1700 (gratis nummer)',
          website: 'vlaanderen.be/premies'
        )
      when 'bruxelles'
        enriched.merge!(
          authority: 'Bruxelles Environnement',
          energy_agency: 'Homegrade',
          main_programs: ['Renolution', 'Prime Energie'],
          contact_center: '02 775 75 75',
          website: 'homegrade.brussels'
        )
      end

      enriched
    end

    def get_wallonie_specifics(contact)
      specifics = []

      # Zones rurales vs urbaines
      if rural_area?(contact.postal_code)
        specifics << 'Prime majorée zone rurale disponible'
        specifics << 'Aide spécifique mazout vers alternatives'
      end

      # Zones de revitalisation urbaine
      if revitalization_zone?(contact.postal_code)
        specifics << 'Zone de revitalisation urbaine - primes majorées'
      end

      # Zones inondables
      if flood_prone_area?(contact.postal_code)
        specifics << 'Zone inondable - primes spéciales résilience'
      end

      specifics
    end

    def get_flandre_specifics(contact)
      specifics = []

      # Zones côtières
      if coastal_area?(contact.postal_code)
        specifics << 'Zone côtière - primes isolation renforcée'
      end

      # Zones urbaines denses
      if dense_urban_area?(contact.postal_code)
        specifics << 'Zone urbaine dense - primes air et bruit'
      end

      specifics
    end

    def get_bruxelles_specifics(contact)
      specifics = []

      # Communes spécifiques
      commune = get_commune_from_postal_code(contact.postal_code)

      case commune
      when 'Ixelles', 'Uccle', 'Woluwe-Saint-Pierre'
        specifics << 'Commune avec primes communales complémentaires'
      when 'Molenbeek', 'Anderlecht', 'Saint-Josse'
        specifics << 'Zone de revitalisation - aides majorées'
      end

      specifics << 'Prime Energie Bruxelles disponible'
      specifics << 'Accompagnement Homegrade gratuit'

      specifics
    end

    def get_postal_code_specifics(postal_code)
      return [] unless postal_code.present?

      specifics = []
      code = postal_code.to_i

      # Zones rurales (codes postaux généralement plus élevés)
      if rural_postal_codes.include?(code)
        specifics << 'Zone rurale - prime isolation majorée'
        specifics << 'Aide spécifique énergies renouvelables'
      end

      # Zones urbaines centrales
      if urban_postal_codes.include?(code)
        specifics << 'Zone urbaine - prime qualité air'
        specifics << 'Accompagnement technique renforcé'
      end

      specifics
    end

    def get_regional_authorities(region)
      authorities = {
        'wallonie' => {
          name: 'SPW Territoire Logement Patrimoine Énergie',
          website: 'energie.wallonie.be',
          phone: '081 33 44 44',
          email: 'info.energie@spw.wallonie.be'
        },
        'flandre' => {
          name: 'Vlaams Energieagentschap (VEA)',
          website: 'vlaanderen.be/energieagentschap',
          phone: '1700',
          email: 'vea@vlaanderen.be'
        },
        'bruxelles' => {
          name: 'Bruxelles Environnement',
          website: 'environnement.brussels',
          phone: '02 775 75 75',
          email: 'info@environnement.brussels'
        }
      }

      authorities[region] || {}
    end

    def get_local_authorities_by_postal_code(postal_code)
      return {} unless postal_code.present?

      # Mapping simplifié code postal -> commune
      # En production, utiliser une base de données complète
      commune_mapping = {
        1000 => 'Bruxelles',
        1050 => 'Ixelles',
        1200 => 'Woluwe-Saint-Lambert',
        4000 => 'Liège',
        5000 => 'Namur',
        9000 => 'Gand'
        # ... etc
      }

      commune = commune_mapping[postal_code.to_i]

      if commune
        {
          commune: commune,
          website: "#{commune.downcase.gsub(' ', '-')}.be",
          services: 'Urbanisme et Environnement'
        }
      else
        {}
      end
    end

    def get_energy_providers(region)
      providers = {
        'wallonie' => ['ORES', 'RESA', 'AIEG'],
        'flandre' => ['Fluvius'],
        'bruxelles' => ['Sibelga']
      }

      providers[region] || []
    end

    def get_social_housing_companies(region, postal_code)
      # Sociétés de logement social par région
      companies = {
        'wallonie' => ['SWL - Société Wallonne du Logement'],
        'flandre' => ['Vlaamse Maatschappij voor Sociaal Wonen'],
        'bruxelles' => ['SLRB - Société du Logement de la Région Bruxelloise']
      }

      companies[region] || []
    end

    def get_service_points(region)
      # Points de service et d'information par région
      {
        'info_energie' => get_energy_info_points(region),
        'guichet_unique' => get_one_stop_shops(region),
        'audit_energetique' => get_energy_audit_centers(region)
      }
    end

    def get_energy_info_points(region)
      points = {
        'wallonie' => [
          { name: 'Guichet Énergie Wallonie', postal_code: 5000 },
          { name: 'Centre Info Énergie Liège', postal_code: 4000 }
        ],
        'flandre' => [
          { name: 'Energiehuis Vlaanderen', postal_code: 9000 },
          { name: 'VEA Informatiecentrum', postal_code: 2000 }
        ],
        'bruxelles' => [
          { name: 'Homegrade Brussels', postal_code: 1000 }
        ]
      }

      points[region] || []
    end

    def get_one_stop_shops(region)
      # Guichets uniques par région
      shops = {
        'wallonie' => [
          { name: 'Guichet Unique Logement', postal_code: 5000 }
        ],
        'flandre' => [
          { name: 'Woonloket Vlaanderen', postal_code: 9000 }
        ],
        'bruxelles' => [
          { name: 'Guichet Logement Bruxelles', postal_code: 1000 }
        ]
      }

      shops[region] || []
    end

    def get_energy_audit_centers(region)
      centers = {
        'wallonie' => [
          { name: 'Centre Audit Énergétique', postal_code: 4000 },
          { name: 'Auditeur Agréé Wallonie', postal_code: 5000 }
        ],
        'flandre' => [
          { name: 'Erkende Energiedeskundige', postal_code: 2000 }
        ],
        'bruxelles' => [
          { name: 'Auditeur Agréé Bruxelles', postal_code: 1000 }
        ]
      }

      centers[region] || []
    end

    def find_nearest_location(postal_code, locations)
      # Algorithme simplifié de calcul de distance
      # En production, utiliser une API de géolocalisation
      return locations.first if locations.empty?

      user_code = postal_code.to_i
      nearest = locations.min_by do |location|
        (location[:postal_code] - user_code).abs
      end

      {
        location: nearest,
        estimated_distance: "#{((nearest[:postal_code] - user_code).abs / 10)}km"
      }
    end

    def get_climate_recommendations(region)
      recommendations = {
        'wallonie' => [
          'Isolation renforcée recommandée (climat continental)',
          'Attention aux ponts thermiques en hiver',
          'Chauffage bois/pellets économique en zone rurale'
        ],
        'flandre' => [
          'Protection contre l\'humidité (climat océanique)',
          'Ventilation renforcée recommandée',
          'Isolation des murs creux prioritaire'
        ],
        'bruxelles' => [
          'Isolation acoustique importante (zone urbaine)',
          'Qualité de l\'air intérieur prioritaire',
          'Solutions compactes pour espaces réduits'
        ]
      }

      recommendations[region] || []
    end

    def get_urban_rural_recommendations(contact)
      return [] unless contact.postal_code.present?

      if rural_area?(contact.postal_code)
        [
          'Énergies renouvelables favorisées (espace disponible)',
          'Chauffage au bois économiquement viable',
          'Récupération eau de pluie recommandée'
        ]
      else
        [
          'Solutions compactes et discrètes',
          'Isolation acoustique renforcée',
          'Ventilation mécanique recommandée'
        ]
      end
    end

    def get_local_building_recommendations(contact)
      # Recommandations selon le type de bâtiment local typique
      recommendations = []

      if contact.respond_to?(:construction_year) && contact.construction_year
        if contact.construction_year < 1945
          recommendations << 'Bâtiment ancien - isolation intérieure privilégiée'
          recommendations << 'Attention au patrimoine architectural'
        elsif contact.construction_year < 1975
          recommendations << 'Période pré-crise énergétique - isolation complète nécessaire'
        end
      end

      recommendations
    end

    # Méthodes utilitaires pour identifier les zones
    def rural_area?(postal_code)
      return false unless postal_code.present?

      # Codes postaux ruraux (simplification)
      rural_codes = (6600..6999).to_a + (4920..4999).to_a + (5580..5680).to_a
      rural_codes.include?(postal_code.to_i)
    end

    def revitalization_zone?(postal_code)
      # Zones de revitalisation urbaine (exemples)
      revitalization_codes = [4000, 4020, 4030, 5000, 5001, 1080, 1070]
      revitalization_codes.include?(postal_code.to_i)
    end

    def flood_prone_area?(postal_code)
      # Zones inondables (simplification basée sur proximité cours d'eau)
      flood_codes = (4400..4499).to_a + (5500..5599).to_a
      flood_codes.include?(postal_code.to_i)
    end

    def coastal_area?(postal_code)
      # Zone côtière flamande
      coastal_codes = (8000..8999).to_a
      coastal_codes.include?(postal_code.to_i)
    end

    def dense_urban_area?(postal_code)
      # Zones urbaines denses
      dense_codes = (2000..2999).to_a + (9000..9999).to_a
      dense_codes.include?(postal_code.to_i)
    end

    def get_commune_from_postal_code(postal_code)
      # Mapping simplifié code postal -> commune Bruxelles
      commune_mapping = {
        1000 => 'Bruxelles',
        1020 => 'Laeken',
        1030 => 'Schaerbeek',
        1040 => 'Etterbeek',
        1050 => 'Ixelles',
        1060 => 'Saint-Gilles',
        1070 => 'Anderlecht',
        1080 => 'Molenbeek',
        1090 => 'Jette',
        1150 => 'Woluwe-Saint-Pierre',
        1180 => 'Uccle',
        1190 => 'Forest'
      }

      commune_mapping[postal_code.to_i]
    end

    def rural_postal_codes
      # Codes postaux ruraux (simplification)
      (6600..6999).to_a + (4920..4999).to_a + (5580..5680).to_a
    end

    def urban_postal_codes
      # Codes postaux urbains
      (1000..1999).to_a + (2000..2999).to_a + (4000..4099).to_a + (9000..9099).to_a
    end
  end
end

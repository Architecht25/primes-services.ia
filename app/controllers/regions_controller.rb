# Contrôleur pour les pages SEO régionales
class RegionsController < ApplicationController
  before_action :set_region

  # Page principale de la région avec contenu SEO riche
  def show
    @region_info = get_region_info
    @major_cities = get_major_cities
    @prime_programs = get_prime_programs
    @faqs = get_region_faqs
  end

  # Page "Primes" de la région (alias vers simulation_primes)
  def primes
    redirect_to simulation_primes_path(region: @region)
  end

  # Page "Villes" de la région
  def cities
    @cities = get_major_cities_detailed
  end

  private

  def set_region
    @region = params[:region]&.downcase
    
    unless ['wallonie', 'flandre', 'bruxelles'].include?(@region)
      redirect_to root_path, alert: "Région non valide"
    end
  end

  def get_region_info
    {
      'wallonie' => {
        name: 'Wallonie',
        full_name: 'Région wallonne',
        language: 'Français',
        capital: 'Namur',
        population: '3,6 millions',
        description: 'La Région wallonne offre un large éventail de primes et subsides pour la rénovation énergétique, l\'isolation, le chauffage et les énergies renouvelables.',
        authority: 'Service Public de Wallonie',
        website: 'https://energie.wallonie.be',
        contact: '1718',
        color: 'blue'
      },
      'flandre' => {
        name: 'Flandre',
        full_name: 'Vlaams Gewest',
        language: 'Néerlandais',
        capital: 'Bruxelles (administratif)',
        population: '6,6 millions',
        description: 'La Flandre propose des primes de rénovation généreuses, des prêts à taux avantageux et un système d\'audit énergétique complet.',
        authority: 'Vlaams Energieagentschap (VEKA)',
        website: 'https://vlaanderen.be/premies',
        contact: '1700',
        color: 'yellow'
      },
      'bruxelles' => {
        name: 'Bruxelles',
        full_name: 'Région de Bruxelles-Capitale',
        language: 'Français/Néerlandais',
        capital: 'Bruxelles',
        population: '1,2 million',
        description: 'Bruxelles-Capitale propose les primes les plus généreuses de Belgique, avec un focus sur la rénovation énergétique et le patrimoine.',
        authority: 'Bruxelles Environnement',
        website: 'https://environnement.brussels',
        contact: '02 775 75 75',
        color: 'green'
      }
    }[@region]
  end

  def get_major_cities
    {
      'wallonie' => ['Liège', 'Charleroi', 'Namur', 'Mons', 'Tournai', 'Verviers', 'La Louvière', 'Seraing'],
      'flandre' => ['Anvers', 'Gand', 'Bruges', 'Louvain', 'Malines', 'Alost', 'Courtrai', 'Ostende'],
      'bruxelles' => ['Bruxelles-Ville', 'Ixelles', 'Uccle', 'Schaerbeek', 'Anderlecht', 'Woluwe-Saint-Lambert', 'Etterbeek', 'Molenbeek']
    }[@region] || []
  end

  def get_major_cities_detailed
    cities = get_major_cities
    cities.map do |city|
      {
        name: city,
        primes_url: simulation_primes_path(region: @region),
        description: "Découvrez les primes disponibles à #{city}"
      }
    end
  end

  def get_prime_programs
    {
      'wallonie' => [
        { name: 'Prime Habitation', description: 'Isolation, chauffage, ventilation', amount: 'Jusqu\'à 30€/m²' },
        { name: 'Rénopack', description: 'Prêt à taux réduit 0-2%', amount: 'Jusqu\'à 60 000€' },
        { name: 'Primes Communales', description: 'Primes locales cumulables', amount: '500€ à 5 000€' },
        { name: 'Prime Audit Énergétique', description: 'Audit logement', amount: '110€ à 660€' }
      ],
      'flandre' => [
        { name: 'Mijn VerbouwPremie', description: 'Prime rénovation globale', amount: 'Variable' },
        { name: 'Energielening', description: 'Prêt énergie 0-2%', amount: 'Jusqu\'à 60 000€' },
        { name: 'Primes Communales', description: 'Primes locales flamandes', amount: '300€ à 4 000€' },
        { name: 'Prime PEB', description: 'Certificat énergétique', amount: 'Jusqu\'à 100€' }
      ],
      'bruxelles' => [
        { name: 'Renolution', description: 'Programme global rénovation', amount: 'Variable' },
        { name: 'Prime Énergie', description: 'Isolation, chauffage, renouvelable', amount: 'Jusqu\'à 50€/m²' },
        { name: 'Prêt Vert', description: 'Financement 0-2%', amount: 'Jusqu\'à 25 000€' },
        { name: 'Primes Communales', description: '19 communes participantes', amount: '400€ à 6 000€' }
      ]
    }[@region] || []
  end

  def get_region_faqs
    {
      'wallonie' => [
        { question: 'Quelles sont les primes disponibles en Wallonie ?', answer: 'La Wallonie offre des primes pour l\'isolation (toiture, murs, sols), le chauffage, la ventilation, l\'audit énergétique et les énergies renouvelables. Les montants varient selon les revenus.' },
        { question: 'Comment obtenir le prêt Rénopack ?', answer: 'Le Rénopack est un prêt à taux réduit (0% à 2%) octroyé par des banques partenaires. Le taux dépend de vos revenus. Maximum 60 000€ sur 10 ans.' },
        { question: 'Puis-je cumuler plusieurs primes ?', answer: 'Oui ! Vous pouvez cumuler les primes régionales avec les primes communales et dans certains cas avec les primes spécifiques (monuments, patrimoine).' }
      ],
      'flandre' => [
        { question: 'Quelles primes en Flandre ?', answer: 'La Flandre propose Mijn VerbouwPremie pour la rénovation, des primes isolation, chauffage, ventilation et panneaux solaires. Le montant dépend de vos revenus.' },
        { question: 'Qu\'est-ce que l\'Energielening ?', answer: 'L\'Energielening est un prêt à taux avantageux (0% à 2%) pour travaux énergétiques. Maximum 60 000€. Le taux dépend de vos revenus.' },
        { question: 'Le certificat PEB est-il obligatoire ?', answer: 'Le certificat PEB (Performance Énergétique du Bâtiment) est obligatoire en Flandre pour certains travaux. Une prime de 100€ existe pour l\'obtenir.' }
      ],
      'bruxelles' => [
        { question: 'Quelles primes à Bruxelles ?', answer: 'Bruxelles offre les primes les plus généreuses : isolation jusqu\'à 75€/m², chauffage, ventilation, énergies renouvelables. Les montants sont majorés pour revenus modestes.' },
        { question: 'C\'est quoi Renolution ?', answer: 'Renolution est le programme bruxellois de rénovation énergétique globale. Il vise à rendre tous les bâtiments bruxellois neutres en carbone d\'ici 2050.' },
        { question: 'Comment cumuler les primes communales ?', answer: 'Les 19 communes bruxelloises offrent des primes complémentaires cumulables avec les primes régionales. Montants de 400€ à 6 000€ selon la commune.' }
      ]
    }[@region] || []
  end
end

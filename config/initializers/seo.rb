# Configuration SEO pour l'application
Rails.application.configure do
  # Configuration du domaine principal pour le SEO
  config.seo = ActiveSupport::OrderedOptions.new

  # URL de base (à configurer selon l'environnement)
  config.seo.base_url = case Rails.env
                        when 'production'
                          'https://primes-services.ia'
                        when 'staging'
                          'https://staging.primes-services.ia'
                        else
                          'http://localhost:3000'
                        end

  # Configuration par défaut des meta tags
  config.seo.default_title = "Primes Services IA - Expert en subsides belges"
  config.seo.default_description = "Assistant IA spécialisé en primes et subsides belges. 324 subsides référencés, calculs instantanés, accompagnement expert. Wallonie, Flandre, Bruxelles."
  config.seo.default_keywords = "primes belges, subsides, wallonie, flandre, bruxelles, IA assistant, primes énergétiques, primes rénovation, aide publique"

  # Open Graph par défaut
  config.seo.og_image = "#{config.seo.base_url}/icon.png"
  config.seo.og_type = "website"
  config.seo.og_locale = "fr_BE"

  # Twitter Cards
  config.seo.twitter_card = "summary_large_image"
  config.seo.twitter_site = "@primes_services" # À ajuster selon votre compte

  # Schema.org
  config.seo.organization_name = "Primes Services IA"
  config.seo.organization_logo = "#{config.seo.base_url}/icon.png"

  # Configuration sitemap
  config.seo.sitemap_host = config.seo.base_url
end

# Configuration du sitemap XML pour le SEO
SitemapGenerator::Sitemap.default_host = ENV.fetch('APP_HOST_URL', 'https://www.primes-services.be')
SitemapGenerator::Sitemap.public_path = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.compress = true

SitemapGenerator::Sitemap.create do
  # Page d'accueil - Priorité maximale
  add root_path, priority: 1.0, changefreq: 'daily'

  # Pages principales - Haute priorité
  add about_path, priority: 0.8, changefreq: 'monthly'

  # Formulaire de contact - Important pour la conversion
  add new_contact_path, priority: 0.9, changefreq: 'monthly'

  # Pages régionales SEO - NOUVEAU pour référencement local
  ['wallonie', 'flandre', 'bruxelles'].each do |region|
    # Page principale de la région - Haute priorité SEO
    add region_path(region: region),
        priority: 0.95,
        changefreq: 'weekly'

    # Page simulation principale par région
    add simulation_region_path(region: region),
        priority: 0.95,
        changefreq: 'weekly'

    # Page primes par région - Très important pour SEO local
    add simulation_primes_path(region: region),
        priority: 0.95,
        changefreq: 'weekly'

    # Page prêts par région
    add simulation_prets_path(region: region),
        priority: 0.90,
        changefreq: 'weekly'
  end

  # Page Ren0vate - Importante pour partenariat/conversion
  add renovate_path, priority: 0.85, changefreq: 'monthly'

  # Pages qui ne doivent PAS être indexées
  # /up - health check
  # /admin/* - zone d'administration
  # /api/* - endpoints API
  # /pwa/* - ressources PWA
  # /redirections/* - redirections internes
end

# Configuration du sitemap XML pour le SEO
SitemapGenerator::Sitemap.default_host = "https://primes-services.ia"
SitemapGenerator::Sitemap.public_path = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.create do
  # Pages principales
  add root_path, :priority => 1.0, :changefreq => 'weekly'
  add about_path, :priority => 0.8, :changefreq => 'monthly'

  # Pages de contact
  add contacts_path, :priority => 0.9, :changefreq => 'monthly'
  add particulier_contacts_path, :priority => 0.8, :changefreq => 'monthly'
  add acp_contacts_path, :priority => 0.8, :changefreq => 'monthly'
  add entreprise_immo_contacts_path, :priority => 0.8, :changefreq => 'monthly'
  add entreprise_comm_contacts_path, :priority => 0.8, :changefreq => 'monthly'

  # Interface IA
  add ai_chat_path, :priority => 0.9, :changefreq => 'weekly'

  # Exclure les pages techniques
  # add '/up' => pas d'indexation pour la page de santé
  # add '/api/*' => pas d'indexation pour les API
end

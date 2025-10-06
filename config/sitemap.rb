# Configuration du sitemap XML pour le SEO
SitemapGenerator::Sitemap.default_host = "https://primes-services.ia"
SitemapGenerator::Sitemap.public_path = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.create do
  # Pages principales
  add root_path, :priority => 1.0, :changefreq => 'weekly'
  add about_path, :priority => 0.8, :changefreq => 'monthly'
  add faq_path, :priority => 0.9, :changefreq => 'weekly'
  add data_path, :priority => 0.8, :changefreq => 'weekly'

  # Pages régionales (Local SEO)
  add region_wallonie_path, :priority => 0.9, :changefreq => 'weekly'
  add region_flandre_path, :priority => 0.9, :changefreq => 'weekly'
  add region_bruxelles_path, :priority => 0.9, :changefreq => 'weekly'

  # Pages par ville (longue traîne SEO)
  # Wallonie
  add '/regions/wallonie/liege', :priority => 0.7, :changefreq => 'monthly'
  add '/regions/wallonie/charleroi', :priority => 0.7, :changefreq => 'monthly'
  add '/regions/wallonie/namur', :priority => 0.7, :changefreq => 'monthly'

  # Flandre
  add '/regions/flandre/anvers', :priority => 0.7, :changefreq => 'monthly'
  add '/regions/flandre/gand', :priority => 0.7, :changefreq => 'monthly'
  add '/regions/flandre/bruges', :priority => 0.7, :changefreq => 'monthly'

  # Bruxelles
  add '/regions/bruxelles/ixelles', :priority => 0.7, :changefreq => 'monthly'
  add '/regions/bruxelles/uccle', :priority => 0.7, :changefreq => 'monthly'

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

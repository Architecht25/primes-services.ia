namespace :seo do
  desc "Génère le sitemap XML pour le SEO"
  task :generate_sitemap => :environment do
    puts "🗺️  Génération du sitemap XML..."

    require 'sitemap_generator'
    SitemapGenerator::Interpreter.run

    puts "✅ Sitemap généré avec succès!"
    puts "📍 Emplacement: #{SitemapGenerator::Sitemap.public_path}#{SitemapGenerator::Sitemap.sitemaps_path}"
  end

  desc "Soumet le sitemap aux moteurs de recherche"
  task :submit_sitemap => :environment do
    sitemap_url = "#{Rails.application.routes.url_helpers.root_url}sitemap.xml"

    puts "🚀 Soumission du sitemap aux moteurs de recherche..."
    puts "📍 URL du sitemap: #{sitemap_url}"

    # Google
    google_ping_url = "https://www.google.com/ping?sitemap=#{CGI.escape(sitemap_url)}"
    puts "📊 Google: #{google_ping_url}"

    # Bing
    bing_ping_url = "https://www.bing.com/ping?sitemap=#{CGI.escape(sitemap_url)}"
    puts "🔍 Bing: #{bing_ping_url}"

    puts "💡 Visitez ces URLs pour soumettre votre sitemap manuellement"
  end

  desc "Vérifie la configuration SEO de l'application"
  task :check => :environment do
    puts "🔍 Vérification de la configuration SEO..."

    # Vérifier robots.txt
    robots_path = Rails.root.join('public', 'robots.txt')
    if File.exist?(robots_path)
      puts "✅ robots.txt trouvé"
    else
      puts "❌ robots.txt manquant"
    end

    # Vérifier sitemap.rb
    sitemap_config = Rails.root.join('config', 'sitemap.rb')
    if File.exist?(sitemap_config)
      puts "✅ Configuration sitemap trouvée"
    else
      puts "❌ Configuration sitemap manquante"
    end

    # Vérifier les meta tags dans le layout
    layout_path = Rails.root.join('app', 'views', 'layouts', 'application.html.erb')
    if File.exist?(layout_path)
      layout_content = File.read(layout_path)

      checks = [
        { name: "Meta description", pattern: /meta.*description/i },
        { name: "Meta keywords", pattern: /meta.*keywords/i },
        { name: "Open Graph", pattern: /property="og:/i },
        { name: "Twitter Cards", pattern: /name="twitter:/i },
        { name: "Canonical URL", pattern: /rel="canonical"/i },
        { name: "Schema.org", pattern: /application\/ld\+json/i }
      ]

      checks.each do |check|
        if layout_content.match?(check[:pattern])
          puts "✅ #{check[:name]} configuré"
        else
          puts "⚠️  #{check[:name]} manquant ou non configuré"
        end
      end
    end

    puts "🎯 Vérification terminée!"
  end
end

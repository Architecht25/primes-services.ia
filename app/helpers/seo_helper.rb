module SeoHelper
  # Génère un titre SEO optimisé
  def seo_title(page_title = nil)
    base_title = "Primes Services IA - Expert en subsides belges"
    return base_title unless page_title.present?

    "#{page_title} | #{base_title}"
  end

  # Génère une meta description optimisée
  def seo_description(description = nil)
    return description if description.present?

    "Assistant IA spécialisé en primes et subsides belges. 324 subsides référencés, calculs instantanés, accompagnement expert. Wallonie, Flandre, Bruxelles."
  end

  # Génère des mots-clés SEO contextuels
  def seo_keywords(*additional_keywords)
    base_keywords = [
      'primes belges', 'subsides', 'wallonie', 'flandre', 'bruxelles',
      'IA assistant', 'primes énergétiques', 'primes rénovation', 'aide publique',
      'expert subsides', 'accompagnement prime', 'calculateur prime'
    ]

    (base_keywords + additional_keywords.flatten).uniq.join(', ')
  end

  # Définit l'URL canonique
  def seo_canonical(url = nil)
    url || request.original_url
  end

  # Helper pour les breadcrumbs (améliore le SEO)
  def breadcrumb_schema(breadcrumbs)
    schema = {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": []
    }

    breadcrumbs.each_with_index do |(name, url), index|
      schema[:itemListElement] << {
        "@type": "ListItem",
        "position": index + 1,
        "name": name,
        "item": url ? "#{request.base_url}#{url}" : nil
      }.compact
    end

    raw("<script type='application/ld+json'>#{schema.to_json}</script>")
  end

  # Helper pour FAQ schema
  def faq_schema(questions_answers)
    schema = {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      "mainEntity": []
    }

    questions_answers.each do |qa|
      schema[:mainEntity] << {
        "@type": "Question",
        "name": qa[:question],
        "acceptedAnswer": {
          "@type": "Answer",
          "text": qa[:answer]
        }
      }
    end

    raw("<script type='application/ld+json'>#{schema.to_json}</script>")
  end

  # Helper pour service schema
  def service_schema(service_name, description)
    schema = {
      "@context": "https://schema.org",
      "@type": "Service",
      "name": service_name,
      "description": description,
      "provider": {
        "@type": "Organization",
        "name": "Primes Services IA",
        "url": request.base_url
      },
      "areaServed": "Belgique",
      "serviceType": "Conseil en subsides"
    }

    raw("<script type='application/ld+json'>#{schema.to_json}</script>")
  end
end

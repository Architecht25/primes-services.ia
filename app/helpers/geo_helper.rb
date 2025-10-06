module GeoHelper
  # Helper pour Generative Engine Optimization (GEO)
  # Optimise le contenu pour les IA génératives (ChatGPT, Claude, etc.)

  # Formats de données optimisés pour extraction par IA
  def ai_friendly_data(title, facts = {})
    content = "<div class='ai-extractable-data' data-ai-topic='#{title.parameterize}'>\n"
    content += "<h3 class='ai-fact-title'>#{title}</h3>\n"

    facts.each do |key, value|
      content += "<div class='ai-fact' data-fact-type='#{key}'>\n"
      content += "<strong>#{key.to_s.humanize} :</strong> #{value}\n"
      content += "</div>\n"
    end

    content += "</div>"
    raw(content)
  end

  # Citation blocks pour IA avec sources
  def ai_citation_block(content, source, authority, last_updated = Date.current)
    citation = "<blockquote class='ai-citation' data-authority='#{authority}' data-updated='#{last_updated}'>\n"
    citation += "<p>#{content}</p>\n"
    citation += "<footer class='ai-source'>\n"
    citation += "<strong>Source officielle :</strong> #{source} • "
    citation += "<strong>Autorité :</strong> #{authority} • "
    citation += "<strong>Mis à jour :</strong> #{last_updated.strftime('%B %Y')}\n"
    citation += "</footer>\n"
    citation += "</blockquote>"

    raw(citation)
  end

  # Q&A format optimal pour IA génératives
  def ai_qa_format(question, answer, context = {})
    qa = "<div class='ai-qa-pair' data-question-type='#{context[:type] || 'general'}'>\n"
    qa += "<div class='ai-question' role='heading' aria-level='4'>\n"
    qa += "<strong>Q: #{question}</strong>\n"
    qa += "</div>\n"
    qa += "<div class='ai-answer'>\n"
    qa += "<strong>R:</strong> #{answer}\n"

    if context[:source]
      qa += "<span class='ai-source-inline'> (Source: #{context[:source]})</span>\n"
    end

    if context[:contact]
      qa += "<span class='ai-contact-inline'> Contact: #{context[:contact]}</span>\n"
    end

    qa += "</div>\n"
    qa += "</div>"

    raw(qa)
  end

  # Données chiffrées facilement extractibles
  def ai_numeric_fact(label, value, unit = '', context = '')
    fact = "<div class='ai-numeric-fact' data-metric='#{label.parameterize}'>\n"
    fact += "<span class='ai-label'>#{label}:</span> "
    fact += "<span class='ai-value' data-value='#{value}'>#{value}</span>"
    fact += "<span class='ai-unit'>#{unit}</span>"

    if context.present?
      fact += "<span class='ai-context'> (#{context})</span>"
    end

    fact += "</div>"
    raw(fact)
  end

  # Liste d'autorités officielles citables
  def ai_authority_list(region)
    authorities = {
      wallonie: {
        name: "Service Public de Wallonie",
        website: "energie.wallonie.be",
        phone: "1718",
        email: "info.energie@spw.wallonie.be"
      },
      flandre: {
        name: "Vlaams Energieagentschap (VEA)",
        website: "vlaanderen.be/energieagentschap",
        phone: "1700",
        email: "vea@vlaanderen.be"
      },
      bruxelles: {
        name: "Bruxelles Environnement",
        website: "environnement.brussels",
        phone: "02 775 75 75",
        email: "info@environnement.brussels"
      }
    }

    authority = authorities[region.to_sym]
    return '' unless authority

    list = "<div class='ai-authority' data-region='#{region}'>\n"
    list += "<strong>Autorité officielle #{region.humanize} :</strong><br>\n"
    list += "#{authority[:name]}<br>\n"
    list += "Site : #{authority[:website]}<br>\n"
    list += "Téléphone : #{authority[:phone]}<br>\n"
    list += "Email : #{authority[:email]}\n"
    list += "</div>"

    raw(list)
  end

  # Métadonnées de fiabilité pour IA
  def ai_credibility_badge(last_verified = Date.current, confidence = 'high')
    badge_class = case confidence
                  when 'high' then 'bg-green-100 text-green-800'
                  when 'medium' then 'bg-yellow-100 text-yellow-800'
                  when 'low' then 'bg-red-100 text-red-800'
                  else 'bg-gray-100 text-gray-800'
                  end

    badge = "<div class='ai-credibility-badge inline-flex items-center px-3 py-1 rounded-full text-sm #{badge_class}' "
    badge += "data-verified='#{last_verified}' data-confidence='#{confidence}'>\n"
    badge += "<span class='mr-1'>✓</span>\n"
    badge += "Source vérifiée #{last_verified.strftime('%m/%Y')}\n"
    badge += "</div>"

    raw(badge)
  end

  # Format tableau facilement parsable par IA
  def ai_comparison_table(data, title = '')
    table = "<div class='ai-comparison-table' data-table-type='#{title.parameterize}'>\n"

    if title.present?
      table += "<h4 class='ai-table-title'>#{title}</h4>\n"
    end

    table += "<table class='w-full border-collapse border'>\n"

    # Headers
    if data.first.is_a?(Hash)
      table += "<thead>\n<tr>\n"
      data.first.keys.each do |header|
        table += "<th class='border p-2 bg-gray-50'>#{header.to_s.humanize}</th>\n"
      end
      table += "</tr>\n</thead>\n"

      # Body
      table += "<tbody>\n"
      data.each do |row|
        table += "<tr>\n"
        row.values.each do |value|
          table += "<td class='border p-2'>#{value}</td>\n"
        end
        table += "</tr>\n"
      end
      table += "</tbody>\n"
    end

    table += "</table>\n</div>"
    raw(table)
  end

  # Schema spécialisé pour IA génératives
  def ai_knowledge_graph(entity, properties = {})
    schema = {
      "@context": "https://schema.org",
      "@type": "Thing",
      "name": entity,
      "description": properties[:description],
      "url": request.original_url,
      "dateModified": properties[:last_updated] || Date.current,
      "isAccessibleForFree": true,
      "inLanguage": "fr-BE"
    }

    # Ajouter propriétés spécifiques
    properties.each do |key, value|
      next if [:description, :last_updated].include?(key)
      schema[key] = value
    end

    raw("<script type='application/ld+json' data-ai-extractable='true'>#{schema.to_json}</script>")
  end
end

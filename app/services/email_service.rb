# Service pour l'envoi d'emails de confirmation et de suivi des contacts
class EmailService
  class << self
    def send_contact_confirmation(contact)
      begin
        # Log pour développement
        Rails.logger.info "Envoi email de confirmation pour contact ##{contact.id} (#{contact.email})"

        # En production, ici on intégrerait avec un service d'email comme:
        # - SendGrid
        # - Mailgun
        # - Amazon SES
        # - Service email Rails (Action Mailer)

        # Pour l'instant, simulation avec log
        email_content = generate_confirmation_email(contact)

        # Simulation d'envoi
        simulate_email_sending(contact.email, "Confirmation de votre demande de primes ##{contact.id}", email_content)

        # Marquer comme envoyé
        contact.update(
          email_sent: true,
          email_sent_at: Time.current
        )

        true
      rescue => e
        Rails.logger.error "Erreur envoi email pour contact ##{contact.id}: #{e.message}"
        false
      end
    end

    def send_ai_analysis_email(contact, ai_analysis)
      begin
        Rails.logger.info "Envoi analyse IA pour contact ##{contact.id}"

        email_content = generate_ai_analysis_email(contact, ai_analysis)

        simulate_email_sending(
          contact.email,
          "Analyse IA de vos opportunités de primes ##{contact.id}",
          email_content
        )

        contact.update(
          ai_analysis_sent: true,
          ai_analysis_sent_at: Time.current
        )

        true
      rescue => e
        Rails.logger.error "Erreur envoi analyse IA pour contact ##{contact.id}: #{e.message}"
        false
      end
    end

    def send_expert_referral_email(contact, expert_info)
      begin
        Rails.logger.info "Envoi référence expert pour contact ##{contact.id}"

        email_content = generate_expert_referral_email(contact, expert_info)

        simulate_email_sending(
          contact.email,
          "Votre expert dédié pour optimiser vos primes ##{contact.id}",
          email_content
        )

        # Également notifier l'expert
        if expert_info[:email]
          expert_content = generate_expert_notification_email(contact)
          simulate_email_sending(
            expert_info[:email],
            "Nouveau client à accompagner - #{contact.type} ##{contact.id}",
            expert_content
          )
        end

        true
      rescue => e
        Rails.logger.error "Erreur envoi référence expert pour contact ##{contact.id}: #{e.message}"
        false
      end
    end

    private

    def generate_confirmation_email(contact)
      profile_name = {
        'ParticulierContact' => 'Particulier',
        'AcpContact' => 'Copropriété (ACP)',
        'EntrepriseImmoContact' => 'Entreprise Immobilière',
        'EntrepriseCommContact' => 'Entreprise Commerciale'
      }[contact.type] || 'Contact'

      <<~EMAIL
        Bonjour #{contact.name},

        Merci pour votre demande de primes et subsides (Référence: ##{contact.id}).

        📋 RÉCAPITULATIF DE VOTRE DEMANDE
        • Profil: #{profile_name}
        • Région: #{contact.region.humanize}
        • Budget estimé: #{contact.estimated_budget ? "#{contact.estimated_budget}€" : 'Non précisé'}
        • Date: #{contact.created_at.strftime('%d/%m/%Y à %H:%M')}

        🤖 ANALYSE IA EN COURS
        Notre intelligence artificielle analyse actuellement votre profil pour identifier:
        • Les primes et subsides les plus pertinents
        • Les conditions d'éligibilité spécifiques
        • L'ordre de priorité des demandes
        • Les optimisations fiscales possibles

        📧 PROCHAINES ÉTAPES
        1. Analyse IA complète sous 24h
        2. Email détaillé avec toutes les opportunités
        3. Contact expert si projet complexe
        4. Accompagnement personnalisé si nécessaire

        💬 QUESTIONS ?
        Vous pouvez continuer la conversation avec notre assistant IA sur:
        #{Rails.application.routes.url_helpers.ai_chat_url}

        Cordialement,
        L'équipe Primes Services IA

        ---
        Cet email est généré automatiquement par notre système d'IA spécialisé en primes belges.
      EMAIL
    end

    def generate_ai_analysis_email(contact, ai_analysis)
      <<~EMAIL
        Bonjour #{contact.name},

        Voici votre analyse IA personnalisée pour maximiser vos primes et subsides.

        🎯 PRIMES PRIORITAIRES IDENTIFIÉES
        #{ai_analysis[:priority_subsidies]&.map { |s| "• #{s}" }&.join("\n") || "• Analyse en cours..."}

        💰 ESTIMATION FINANCIÈRE
        • Montant total potentiel: #{ai_analysis[:total_potential] || 'En calcul...'}
        • Primes immédiates: #{ai_analysis[:immediate_grants] || 'À déterminer'}
        • Économies fiscales: #{ai_analysis[:tax_savings] || 'À calculer'}

        📋 PLAN D'ACTION RECOMMANDÉ
        #{ai_analysis[:action_plan] || contact.generate_personalized_message}

        🔗 LIENS UTILES
        #{ai_analysis[:useful_links]&.map { |link| "• #{link}" }&.join("\n") || "• Documentation en préparation"}

        Pour des questions spécifiques, notre assistant IA reste disponible 24h/7j.

        Cordialement,
        L'équipe Primes Services IA
      EMAIL
    end

    def generate_expert_referral_email(contact, expert_info)
      <<~EMAIL
        Bonjour #{contact.name},

        Excellente nouvelle ! Notre IA a identifié que votre projet peut bénéficier d'un accompagnement expert personnalisé.

        👨‍💼 VOTRE EXPERT DÉDIÉ
        • Nom: #{expert_info[:name] || 'Expert spécialisé'}
        • Spécialité: #{expert_info[:specialty] || contact.type}
        • Email: #{expert_info[:email] || 'expert@primes-services.be'}
        • Téléphone: #{expert_info[:phone] || '+32 2 123 45 67'}

        🎯 ACCOMPAGNEMENT INCLUS
        • Audit complet de votre éligibilité
        • Optimisation du montage financier
        • Accompagnement administratif
        • Suivi jusqu'à l'obtention des primes

        📞 RENDEZ-VOUS
        Votre expert vous contactera sous 48h pour fixer un premier rendez-vous gratuit.

        Référence de votre dossier: ##{contact.id}

        Cordialement,
        L'équipe Primes Services IA
      EMAIL
    end

    def generate_expert_notification_email(contact)
      <<~EMAIL
        Nouveau client à accompagner

        Profil: #{contact.type}
        Référence: ##{contact.id}
        Nom: #{contact.name}
        Email: #{contact.email}
        Téléphone: #{contact.phone}
        Région: #{contact.region}
        Budget: #{contact.estimated_budget}€

        Message: #{contact.message}

        Complexité estimée: #{contact.respond_to?(:business_complexity_score) ? contact.business_complexity_score : 'Standard'}

        Prendre contact sous 48h.
      EMAIL
    end

    def simulate_email_sending(to_email, subject, content)
      # En développement, on log l'email au lieu de l'envoyer
      if Rails.env.development?
        Rails.logger.info <<~LOG
          ================== EMAIL SIMULATION ==================
          TO: #{to_email}
          SUBJECT: #{subject}

          #{content}
          =======================================================
        LOG
      else
        # En production, ici on utiliserait un vrai service d'email
        # Exemple avec Action Mailer:
        # ContactMailer.confirmation_email(to_email, subject, content).deliver_now
      end
    end
  end
end

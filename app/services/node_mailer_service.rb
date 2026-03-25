# NodeMailerService – appelle le script nodemailer pour envoyer les emails via Office 365.
# Contourne les limitations de l'auth SMTP basique de Rails avec les Security Defaults Azure AD.
class NodeMailerService
  MAILER_SCRIPT = Rails.root.join("emailer", "mailer.js").to_s

  class << self
    def send_mail(to:, subject:, html: "", text: "")
      payload = JSON.generate({ to: to, subject: subject, html: html, text: text })

      env = {
        "SMTP_HOST"     => ENV.fetch("SMTP_HOST", "smtp.office365.com"),
        "SMTP_PORT"     => ENV.fetch("SMTP_PORT", "587"),
        "SMTP_USERNAME" => ENV["SMTP_USERNAME"],
        "SMTP_PASSWORD" => ENV["SMTP_PASSWORD"]
      }

      output, status = Open3.capture2e(env, "node", MAILER_SCRIPT, payload)

      if status.success?
        Rails.logger.info "[NodeMailer] Email envoyé à #{to}: #{output.strip}"
        true
      else
        Rails.logger.error "[NodeMailer] Échec envoi à #{to}: #{output.strip}"
        false
      end
    end
  end
end

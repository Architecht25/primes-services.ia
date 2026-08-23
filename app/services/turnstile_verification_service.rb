# Vérifie les jetons Cloudflare Turnstile (widget anti-bot du formulaire de contact)
# côté serveur, via l'API siteverify de Cloudflare.
# https://developers.cloudflare.com/turnstile/get-started/server-side-validation/
class TurnstileVerificationService
  SITEVERIFY_URL = "https://challenges.cloudflare.com/turnstile/v0/siteverify".freeze

  class << self
    # Retourne true si le jeton est valide, ou si Turnstile n'est pas configuré
    # (fail-open : on ne veut pas perdre toutes les demandes de contact si la
    # clé n'a pas encore été renseignée, mais on le signale bruyamment).
    def verify(token, remote_ip:)
      secret_key = ENV["TURNSTILE_SECRET_KEY"].presence

      if secret_key.nil?
        Rails.logger.error "[Security] TURNSTILE_SECRET_KEY absent — vérification anti-bot désactivée !" if Rails.env.production?
        return true
      end

      return false if token.blank?

      response = HTTParty.post(
        SITEVERIFY_URL,
        body: { secret: secret_key, response: token, remoteip: remote_ip },
        timeout: 5
      )

      response.parsed_response["success"] == true
    rescue => e
      # En cas de panne de l'API Cloudflare, on ne bloque pas les vrais visiteurs.
      Rails.logger.error "[Security] Échec de vérification Turnstile: #{e.message}"
      true
    end
  end
end

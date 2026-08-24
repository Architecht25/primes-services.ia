class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # L'apex primes-services.be et le sous-domaine www pointent tous les deux
  # vers cette app sur Heroku. On force un seul host canonique (www) pour
  # éviter le contenu dupliqué en SEO et rester cohérent avec le sitemap.
  APEX_HOST = "primes-services.be"
  CANONICAL_HOST = "www.primes-services.be"

  before_action :redirect_apex_to_www

  # Endpoint pour vérification de connectivité (utilisé par offline controller)
  def ping
    head :ok
  end

  private

  def redirect_apex_to_www
    return unless request.host == APEX_HOST

    redirect_to "#{request.protocol}#{CANONICAL_HOST}#{request.fullpath}", status: :moved_permanently
  end
end

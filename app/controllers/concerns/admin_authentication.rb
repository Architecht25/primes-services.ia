# Concern pour l'authentification admin
# Utilise un formulaire de login avec session (remplace HTTP Basic Auth)
module AdminAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_admin!
  end

  private

  def authenticate_admin!
    return true if admin_authenticated?

    redirect_to admin_login_path, alert: "Accès réservé à l'administration."
  end

  def admin_authenticated?
    session[:admin_authenticated] == true
  end

  def current_admin
    session[:admin_username] if admin_authenticated?
  end
end

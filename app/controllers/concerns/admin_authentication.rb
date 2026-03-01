# Concern pour l'authentification admin
# Utilise HTTP Basic Auth avec credentials stockés dans ENV
module AdminAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_admin!
  end

  private

  def authenticate_admin!
    return true if admin_authenticated?

    authenticate_or_request_with_http_basic('Administration Primes Services') do |username, password|
      admin_username = ENV['ADMIN_USERNAME'] || 'admin'
      admin_password = ENV['ADMIN_PASSWORD'] || 'changeme123'

      username == admin_username && password == admin_password
    end
  end

  def admin_authenticated?
    session[:admin_authenticated] == true
  end

  def current_admin
    session[:admin_username] if admin_authenticated?
  end
end

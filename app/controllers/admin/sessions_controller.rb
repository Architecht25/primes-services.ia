class Admin::SessionsController < ApplicationController
  layout false  # sessions/new.html.erb is a standalone HTML page

  def new
    redirect_to admin_root_path if admin_authenticated?
  end

  def create
    username = params[:username]&.strip
    password = params[:password]

    admin_username = ENV['ADMIN_USERNAME'].presence
    admin_password = ENV['ADMIN_PASSWORD'].presence

    if admin_username.nil? || admin_password.nil?
      Rails.logger.error "[Security] ADMIN_USERNAME or ADMIN_PASSWORD env vars not set!"
      redirect_to admin_login_path, alert: "Configuration serveur incorrecte." and return
    end

    if ActiveSupport::SecurityUtils.secure_compare(username.to_s, admin_username) &
       ActiveSupport::SecurityUtils.secure_compare(password.to_s, admin_password)

      session[:admin_authenticated] = true
      session[:admin_username] = username

      SecurityLog.create!(
        event_type: 'admin_login_success',
        severity: 'info',
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        description: "Admin login réussi pour '#{username}'"
      )

      redirect_to admin_root_path, notice: "Connecté."
    else
      SecurityLog.create!(
        event_type: 'admin_login_failure',
        severity: 'warning',
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        description: "Tentative de connexion échouée pour '#{username}'"
      )

      redirect_to admin_login_path, alert: "Identifiants incorrects."
    end
  end

  def destroy
    session.delete(:admin_authenticated)
    session.delete(:admin_username)
    redirect_to admin_login_path, notice: "Déconnecté."
  end

  private

  def admin_authenticated?
    session[:admin_authenticated] == true
  end
end

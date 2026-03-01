# Contrôleur de base pour l'administration
class Admin::BaseController < ApplicationController
  include AdminAuthentication

  layout 'admin'

  before_action :set_admin_context

  private

  def set_admin_context
    @admin_user = current_admin
  end
end

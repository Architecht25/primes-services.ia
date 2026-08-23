# Contrôleur du tableau de bord administrateur
class Admin::DashboardController < Admin::BaseController
  def index
    @stats = build_dashboard_stats
  end

  private

  # Chaque section est calculée indépendamment : une erreur sur l'une d'elles
  # n'invalide pas tout le dashboard (contrairement à l'ancien rescue global).
  def build_dashboard_stats
    {
      contacts: safely("contacts") { contacts_stats },
      renovate: safely("renovate") { renovate_stats },
      security: safely("security") { SecurityMonitorService.health_check },
      system: safely("system") { system_stats }
    }
  end

  def safely(section)
    yield
  rescue => e
    Rails.logger.error "[Dashboard] Error building '#{section}' stats: #{e.message}"
    {}
  end

  def contacts_stats
    {
      total: ContactSubmission.count,
      today: ContactSubmission.where('created_at >= ?', Time.zone.today).count,
      week: ContactSubmission.where('created_at >= ?', 1.week.ago).count,
      month: ContactSubmission.where('created_at >= ?', 1.month.ago).count,
      by_type: ContactSubmission.group(:type).count,
      unread: ContactSubmission.where(read_at: nil).count
    }
  end

  def renovate_stats
    {
      total_clicks:    RenovateClick.clicks.count,
      total_redirects: RenovateClick.redirects.count,
      today:           RenovateClick.today.count,
      week:            RenovateClick.this_week.count,
      by_profile:      RenovateClick.this_week.group(:profile).count,
      by_region:       RenovateClick.this_week.group(:region).count
    }
  end

  def system_stats
    {
      rails_version: Rails.version,
      ruby_version: RUBY_VERSION,
      environment: Rails.env,
      uptime: (Time.current - Rails.application.config.booted_at rescue 0)
    }
  end
end

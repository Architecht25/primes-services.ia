# Contrôleur du tableau de bord administrateur
class Admin::DashboardController < Admin::BaseController
  def index
    @stats = build_dashboard_stats
  end

  private

  def build_dashboard_stats
    {
      contacts: {
        total: ContactSubmission.count,
        today: ContactSubmission.where('created_at >= ?', Time.zone.today).count,
        week: ContactSubmission.where('created_at >= ?', 1.week.ago).count,
        month: ContactSubmission.where('created_at >= ?', 1.month.ago).count,
        by_type: ContactSubmission.group(:submission_type).count
      },
      ai_conversations: {
        total: AiConversation.count,
        active: AiConversation.where(status: 'active').count,
        today: AiConversation.where('created_at >= ?', Time.zone.today).count,
        week: AiConversation.where('created_at >= ?', 1.week.ago).count
      },
      analytics: AnalyticsService.summary_stats,
      security: SecurityMonitorService.health_check,
      system: {
        rails_version: Rails.version,
        ruby_version: RUBY_VERSION,
        environment: Rails.env,
        uptime: (Time.current - Rails.application.config.booted_at rescue 0)
      }
    }
  rescue => e
    Rails.logger.error "Error building dashboard stats: #{e.message}"
    {}
  end
end

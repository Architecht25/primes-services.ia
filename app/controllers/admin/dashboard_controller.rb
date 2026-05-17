# Contrôleur du tableau de bord administrateur
class Admin::DashboardController < Admin::BaseController
  def index
    @stats = build_dashboard_stats
  end

  private

  def build_dashboard_stats
    total_convs  = AiConversation.count
    total_leads  = AiConversation.where("metadata->>'lead_email' IS NOT NULL").count
    leads_today  = AiConversation.where("metadata->>'lead_email' IS NOT NULL")
                                 .where('created_at >= ?', Time.zone.today).count
    leads_week   = AiConversation.where("metadata->>'lead_email' IS NOT NULL")
                                 .where('created_at >= ?', 1.week.ago).count
    convs_week   = AiConversation.where('created_at >= ?', 1.week.ago).count

    {
      contacts: {
        total: ContactSubmission.count,
        today: ContactSubmission.where('created_at >= ?', Time.zone.today).count,
        week: ContactSubmission.where('created_at >= ?', 1.week.ago).count,
        month: ContactSubmission.where('created_at >= ?', 1.month.ago).count,
        by_type: ContactSubmission.group(:submission_type).count,
        unread: ContactSubmission.where(read_at: nil).count
      },
      ai_conversations: {
        total: total_convs,
        active: AiConversation.where(status: 'active').count,
        today: AiConversation.where('created_at >= ?', Time.zone.today).count,
        week: convs_week
      },
      ai_leads: {
        total: total_leads,
        today: leads_today,
        week: leads_week,
        conversion_rate: total_convs > 0 ? (total_leads.to_f / total_convs * 100).round(1) : 0,
        week_conversion_rate: convs_week > 0 ? (leads_week.to_f / convs_week * 100).round(1) : 0,
        by_region: AiConversation.where("metadata->>'lead_email' IS NOT NULL")
                                 .group(:user_region).count
      },
      funnel: {
        visitors: PageVisit.where('created_at >= ?', 30.days.ago).distinct.count(:visitor_id),
        chat_sessions: AiConversation.where('created_at >= ?', 30.days.ago).count,
        leads_captured: AiConversation.where("metadata->>'lead_email' IS NOT NULL")
                                      .where('created_at >= ?', 30.days.ago).count,
        contact_forms: ContactSubmission.where('created_at >= ?', 30.days.ago).count,
        renovate_clicks: RenovateClick.recent.count
      },
      renovate: {
        total_clicks:    RenovateClick.clicks.count,
        total_redirects: RenovateClick.redirects.count,
        today:           RenovateClick.today.count,
        week:            RenovateClick.this_week.count,
        by_profile:      RenovateClick.this_week.group(:profile).count,
        by_region:       RenovateClick.this_week.group(:region).count
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

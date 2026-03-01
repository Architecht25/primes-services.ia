# Service pour tracker et analyser les visites du site
class AnalyticsService
  class << self
    # Résumé rapide des stats
    def summary_stats
      {
        total_visits: PageVisit.count,
        unique_visitors: PageVisit.distinct.count(:visitor_id),
        today_visits: PageVisit.where('created_at >= ?', Time.zone.today).count,
        bounce_rate: calculate_bounce_rate,
        avg_session_duration: calculate_avg_session_duration
      }
    rescue => e
      Rails.logger.error "Analytics summary error: #{e.message}"
      default_stats
    end

    # Stats détaillées par période
    def detailed_stats(period = 'week')
      start_date = case period
      when 'today' then Time.zone.today
      when 'week' then 1.week.ago
      when 'month' then 1.month.ago
      when 'year' then 1.year.ago
      else 1.week.ago
      end

      visits = PageVisit.where('created_at >= ?', start_date)

      {
        total_visits: visits.count,
        unique_visitors: visits.distinct.count(:visitor_id),
        visits_by_date: visits.group_by_day(:created_at).count,
        top_pages: visits.group(:page_path).order('count_id DESC').limit(10).count(:id),
        by_region: visits.group(:user_region).count,
        by_device: visits.group(:device_type).count,
        referrers: visits.where.not(referrer: nil).group(:referrer).order('count_id DESC').limit(10).count(:id)
      }
    end

    # Stats en temps réel (dernière heure)
    def real_time_stats
      recent_visits = PageVisit.where('created_at >= ?', 1.hour.ago)

      {
        active_now: recent_visits.where('created_at >= ?', 5.minutes.ago).count,
        last_hour: recent_visits.count,
        current_pages: recent_visits.group(:page_path).count,
        regions: recent_visits.group(:user_region).count
      }
    end

    # Stats par page
    def page_stats(start_date: 1.month.ago, end_date: Time.current)
      PageVisit.where(created_at: start_date..end_date)
        .group(:page_path)
        .select('page_path, COUNT(*) as visits, COUNT(DISTINCT visitor_id) as unique_visitors, AVG(time_on_page) as avg_time')
        .order('visits DESC')
    end

    # Stats par source de trafic
    def referrer_stats
      PageVisit.where.not(referrer: nil)
        .group(:referrer)
        .order('count_id DESC')
        .limit(20)
        .count(:id)
    end

    # Stats par région
    def region_stats
      {
        total_by_region: PageVisit.group(:user_region).count,
        conversions_by_region: ContactSubmission.group(:region).count,
        popular_pages_by_region: popular_pages_by_region
      }
    end

    # Enregistrer une nouvelle visite
    def track_visit(request, page_path, user_region: nil)
      PageVisit.create!(
        visitor_id: get_or_create_visitor_id(request),
        page_path: page_path,
        referrer: request.referer,
        user_agent: request.user_agent,
        ip_address: request.remote_ip,
        user_region: user_region,
        device_type: detect_device_type(request.user_agent),
        session_id: request.session.id
      )
    rescue => e
      Rails.logger.error "Failed to track visit: #{e.message}"
      nil
    end

    private

    def calculate_bounce_rate
      # Simplifié: sessions avec une seule page vue
      total_sessions = PageVisit.distinct.count(:session_id)
      return 0 if total_sessions.zero?

      single_page_sessions = PageVisit.group(:session_id).count.count { |_, count| count == 1 }
      ((single_page_sessions.to_f / total_sessions) * 100).round(2)
    end

    def calculate_avg_session_duration
      # Durée moyenne en secondes (simplifié)
      PageVisit.where.not(time_on_page: nil).average(:time_on_page)&.to_f&.round(0) || 0
    end

    def popular_pages_by_region
      PageVisit.group(:user_region, :page_path)
        .order('count_id DESC')
        .limit(50)
        .count(:id)
    end

    def get_or_create_visitor_id(request)
      request.session[:visitor_id] ||= SecureRandom.uuid
    end

    def detect_device_type(user_agent)
      return 'unknown' if user_agent.blank?

      ua = user_agent.downcase
      return 'mobile' if ua.match?(/mobile|android|iphone|ipad|phone/)
      return 'tablet' if ua.match?(/tablet|ipad/)
      'desktop'
    end

    def default_stats
      {
        total_visits: 0,
        unique_visitors: 0,
        today_visits: 0,
        bounce_rate: 0,
        avg_session_duration: 0
      }
    end
  end
end

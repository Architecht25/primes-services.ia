# Contrôleur pour les analytics et statistiques
class Admin::AnalyticsController < Admin::BaseController
  def index
    @period = params[:period] || 'week'
    @analytics = AnalyticsService.detailed_stats(@period)
    @chart_data = prepare_chart_data(@analytics)
  end

  def real_time
    @live_stats = AnalyticsService.real_time_stats

    respond_to do |format|
      format.html
      format.json { render json: @live_stats }
    end
  end

  def pages
    @page_stats = AnalyticsService.page_stats(
      start_date: params[:start_date],
      end_date: params[:end_date]
    )
  end

  def referrers
    @referrer_stats = AnalyticsService.referrer_stats
  end

  def regions
    @region_stats = AnalyticsService.region_stats
  end

  private

  def prepare_chart_data(analytics)
    {
      visits: analytics[:visits_by_date].map { |date, count| [date.to_s, count] },
      pages: analytics[:top_pages].map { |page, count| [page, count] },
      regions: analytics[:by_region].map { |region, count| [region.titleize, count] }
    }
  end
end

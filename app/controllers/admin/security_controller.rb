# Contrôleur pour le monitoring de sécurité
class Admin::SecurityController < Admin::BaseController
  def index
    @security_status = SecurityMonitorService.full_report
  end

  def logs
    @security_logs = SecurityLog.order(created_at: :desc).limit(100)

    if params[:severity].present?
      @security_logs = @security_logs.where(severity: params[:severity])
    end
  end

  def scan
    @scan_results = SecurityMonitorService.run_security_scan

    respond_to do |format|
      format.html
      format.json { render json: @scan_results }
    end
  end

  def health
    @health_status = {
      database: check_database,
      redis: check_redis,
      storage: check_storage,
      ssl: check_ssl,
      headers: check_security_headers
    }

    respond_to do |format|
      format.html
      format.json { render json: @health_status }
    end
  end

  private

  def check_database
    ActiveRecord::Base.connection.execute('SELECT 1')
    { status: 'ok', latency: measure_db_latency }
  rescue => e
    { status: 'error', message: e.message }
  end

  def check_redis
    # Si vous utilisez Redis/Solid Cache
    Rails.cache.write('health_check', true)
    Rails.cache.read('health_check')
    { status: 'ok' }
  rescue => e
    { status: 'error', message: e.message }
  end

  def check_storage
    total_space = `df -h / | tail -1 | awk '{print $2}'`.strip
    used_space = `df -h / | tail -1 | awk '{print $3}'`.strip
    available_space = `df -h / | tail -1 | awk '{print $4}'`.strip
    usage_percent = `df -h / | tail -1 | awk '{print $5}'`.strip

    {
      status: 'ok',
      total: total_space,
      used: used_space,
      available: available_space,
      usage: usage_percent
    }
  rescue => e
    { status: 'error', message: e.message }
  end

  def check_ssl
    # Vérifier si on est en HTTPS
    {
      status: request.ssl? ? 'ok' : 'warning',
      ssl_enabled: request.ssl?,
      protocol: request.protocol
    }
  end

  def check_security_headers
    headers_to_check = %w[
      X-Frame-Options
      X-Content-Type-Options
      X-XSS-Protection
      Strict-Transport-Security
      Content-Security-Policy
    ]

    headers_to_check.map do |header|
      {
        header: header,
        present: response.headers[header].present?,
        value: response.headers[header]
      }
    end
  end

  def measure_db_latency
    start_time = Time.now
    ActiveRecord::Base.connection.execute('SELECT 1')
    ((Time.now - start_time) * 1000).round(2) # en ms
  end
end

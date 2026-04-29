Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']

  # Active uniquement si DSN configuré
  config.enabled_environments = %w[production]

  # Capturer les erreurs Rails + Active Job
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Exclure les paramètres sensibles
  config.send_default_pii = false

  # Taux d'échantillonnage pour les traces de performance (10% en prod)
  config.traces_sample_rate = 0.1
end

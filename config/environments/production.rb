require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = ENV['AWS_BUCKET'].present? ? :amazon : :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Durable cache store backed by the database (solid_cache gem).
  config.cache_store = :solid_cache_store

  # Durable job queue backed by the database (solid_queue gem).
  config.active_job.queue_adapter = :solid_queue
  # Single primary DB — no separate queue database

  # Email delivery via Resend (même config que ren0vate)
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp

  # Set host to be used by links generated in mailer templates.
  # NB: the bare apex (primes-services.be) currently redirects to the raw
  # Heroku hostname at the DNS/registrar level — only "www" resolves to the
  # app directly. Using the apex here would put a broken-looking redirect
  # hop in every mailer link, so default to "www" until the apex redirect
  # is fixed to point at https://www.primes-services.be instead.
  config.action_mailer.default_url_options = {
    host: ENV.fetch('APP_HOST', 'www.primes-services.be'),
    protocol: 'https'
  }

  # Configuration SMTP via Resend (domaine primes-services.be vérifié sur Resend)
  config.action_mailer.smtp_settings = {
    address:              ENV.fetch('SMTP_ADDRESS', 'smtp.resend.com'),
    port:                 ENV.fetch('SMTP_PORT', 587).to_i,
    domain:               ENV.fetch('SMTP_DOMAIN', 'primes-services.be'),
    user_name:            ENV.fetch('SMTP_USERNAME', 'resend'),
    password:             ENV['SMTP_PASSWORD'],
    authentication:       :plain,
    enable_starttls_auto: true
  }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # Both the apex and "www" are attached to the Heroku app as of 2026-08-24
  # (apex ALIASes directly to Heroku now — no more DNS-level redirect through
  # a raw platform hostname). The apex is 301-redirected to "www" at the app
  # level below to keep a single canonical host for SEO.
  config.hosts = [
    "www.primes-services.be",
    "primes-services.be",
    "primes-services-ia-cc4318abe295.herokuapp.com"
  ]

  # Skip DNS rebinding protection for the default health check endpoint.
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end

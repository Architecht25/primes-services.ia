class Rack::Attack
  # Throttle contact form submissions: max 5 per minute per IP
  throttle('contacts/create', limit: 5, period: 1.minute) do |req|
    req.ip if req.post? && req.path == '/contacts'
  end

  # Throttle AI chatbot messages: max 20 per minute per IP
  throttle('ai/send_message', limit: 20, period: 1.minute) do |req|
    req.ip if req.post? && req.path == '/ai/send_message'
  end

  # Throttle admin login attempts: max 5 per 5 minutes per IP
  throttle('admin/login', limit: 5, period: 5.minutes) do |req|
    req.ip if req.post? && req.path == '/admin/login'
  end

  # Block completely after 15 failed attempts in 1 hour (IP-level lockout)
  blocklist('admin/login/block') do |req|
    Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 15, findtime: 1.hour, bantime: 1.hour) do
      req.post? && req.path == '/admin/login'
    end
  end

  # Block requests with suspicious user agents (empty or known scanner patterns)
  blocklist('block/suspicious_agents') do |req|
    req.user_agent.blank? ||
      req.user_agent.match?(/\A(curl|python-requests|go-http-client|libwww-perl)\//i) &&
      req.post?
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    [
      429,
      { 'Content-Type' => 'application/json', 'Retry-After' => '60' },
      [{ error: 'Trop de requêtes. Veuillez réessayer dans quelques instants.' }.to_json]
    ]
  end
end

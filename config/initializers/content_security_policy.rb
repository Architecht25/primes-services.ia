# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    # Nonce-based enforcement: Rails injects the nonce automatically via
    # content_security_policy_nonce_directives below — do NOT list :nonce here.
    policy.script_src  :self, :https
    # Tailwind is compiled to a static file, but many views + Turbo use inline
    # style attributes/elements — unsafe-inline is needed here. The critical
    # protection is the nonce on script-src below.
    policy.style_src   :self, :https, :unsafe_inline
    policy.connect_src :self, :https
    policy.frame_ancestors :none
  end

  # Generate a per-request nonce tied to the session
  config.content_security_policy_nonce_generator = ->(request) {
    request.session.id.to_s.presence || SecureRandom.base64(16)
  }
  config.content_security_policy_nonce_directives = %w[script-src]
end

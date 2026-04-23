class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "Primes Services <noreply@ren0vate.be>")
  layout "mailer"
end

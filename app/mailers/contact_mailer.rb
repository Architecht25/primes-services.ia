class ContactMailer < ApplicationMailer
  def new_submission_notification(contact)
    @contact = contact
    mail(
      to: ENV.fetch("TEAM_EMAIL", "robin@primes-services.be"),
      subject: "[Nouvelle demande] #{contact.name} (##{contact.id}) – #{contact.region&.humanize}"
    )
  end
end

class ContactMailer < ApplicationMailer
  ADMIN_EMAIL = "robin@primes-services.be"

  def new_submission_notification(contact)
    @contact = contact
    mail(
      to: ADMIN_EMAIL,
      subject: "[Nouvelle demande] #{contact.name} (##{contact.id}) – #{contact.region&.humanize}"
    )
  end
end

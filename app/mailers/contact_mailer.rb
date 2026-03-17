class ContactMailer < ApplicationMailer
  ADMIN_EMAIL = "robin@primes-services.be"

  def new_submission_notification(contact)
    @contact = contact
    mail(
      to: ADMIN_EMAIL,
      subject: "[Nouvelle demande] #{contact_type_label} – #{contact.name} (##{contact.id})"
    )
  end

  private

  def contact_type_label
    {
      "ParticulierContact"     => "Particulier",
      "AcpContact"             => "Copropriété (ACP)",
      "EntrepriseImmoContact"  => "Entreprise Immobilière",
      "EntrepriseCommContact"  => "Entreprise Commerciale"
    }[@contact.type] || "Contact"
  end
  helper_method :contact_type_label
end

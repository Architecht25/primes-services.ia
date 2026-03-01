# Service pour exporter les contacts au format CSV
class ContactExportService
  require 'csv'

  class << self
    def to_csv(contacts)
      CSV.generate(headers: true) do |csv|
        # En-têtes
        csv << [
          'ID',
          'Date de soumission',
          'Type',
          'Prénom',
          'Nom',
          'Email',
          'Téléphone',
          'Région',
          'Code postal',
          'Ville',
          'Type de bien',
          'Type de travaux',
          'Message',
          'Statut',
          'Lu le',
          'IP'
        ]

        # Données
        contacts.each do |contact|
          csv << [
            contact.id,
            contact.created_at.strftime('%d/%m/%Y %H:%M'),
            contact.submission_type,
            contact.first_name,
            contact.last_name,
            contact.email,
            contact.phone,
            contact.region,
            contact.postal_code,
            contact.city,
            contact.property_type,
            contact.work_type,
            contact.message,
            contact.read? ? 'Lu' : 'Non lu',
            contact.read_at&.strftime('%d/%m/%Y %H:%M'),
            contact.ip_address
          ]
        end
      end
    end

    def to_json(contacts)
      contacts.as_json(
        only: [:id, :email, :phone, :first_name, :last_name, :region, :submission_type, :created_at],
        methods: [:read?]
      )
    end
  end
end

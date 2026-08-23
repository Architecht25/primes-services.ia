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
          'Nom',
          'Email',
          'Téléphone',
          'Région',
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
            contact.type,
            contact.name,
            contact.email,
            contact.phone,
            contact.region,
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
        only: [:id, :email, :phone, :name, :region, :type, :created_at],
        methods: [:read?]
      )
    end
  end
end

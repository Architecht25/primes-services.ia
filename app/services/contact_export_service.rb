# Service pour exporter les contacts au format CSV
class ContactExportService
  require 'csv'

  # Caractères qui, en tête de cellule, sont interprétés comme le début
  # d'une formule par Excel/LibreOffice/Google Sheets (CSV/Formula Injection).
  # Comme le contenu vient de soumissions publiques non fiables, on neutralise
  # ces cellules avant de générer le CSV.
  FORMULA_TRIGGER_CHARS = ["=", "+", "-", "@", "\t", "\r"].freeze

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
            sanitize_cell(contact.name),
            sanitize_cell(contact.email),
            sanitize_cell(contact.phone),
            sanitize_cell(contact.region),
            sanitize_cell(contact.message),
            contact.read? ? 'Lu' : 'Non lu',
            contact.read_at&.strftime('%d/%m/%Y %H:%M'),
            contact.ip_address
          ]
        end
      end
    end

    # Préfixe d'une apostrophe toute valeur commençant par un caractère
    # déclencheur de formule, pour forcer les tableurs à la traiter comme
    # du texte brut plutôt que comme une formule à évaluer.
    def sanitize_cell(value)
      return value unless value.is_a?(String)
      return value unless FORMULA_TRIGGER_CHARS.include?(value[0])

      "'#{value}"
    end

    def to_json(contacts)
      contacts.as_json(
        only: [:id, :email, :phone, :name, :region, :type, :created_at],
        methods: [:read?]
      )
    end
  end
end

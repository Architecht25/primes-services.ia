class CreateContactSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_submissions do |t|
      t.string :type, null: false                    # STI type
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :region, null: false                  # wallonie, flandre, bruxelles
      t.text :message
      t.string :status, default: 'pending'          # pending, processed, completed, archived
      t.json :metadata                               # Champs spécialisés par type
      t.datetime :submitted_at
      t.datetime :processed_at

      # Champs spécialisés Particuliers
      t.string :property_type                        # maison, appartement
      t.integer :construction_year
      t.string :work_type                           # isolation, chauffage, renovation_globale
      t.decimal :estimated_budget, precision: 10, scale: 2
      t.string :realization_deadline                # urgent, cette_annee, flexible
      t.text :family_situation

      # Champs spécialisés ACP (Associations Copropriétaires)
      t.integer :number_of_units
      t.string :building_type                       # residentiel, mixte
      t.string :building_work_type                  # facade, toiture, chauffage, isolation
      t.decimal :voted_budget, precision: 12, scale: 2
      t.string :syndic_contact
      t.string :work_urgency                        # urgent, planifie, etude

      # Champs spécialisés Entreprises Immobilières
      t.string :business_activity                   # promotion, gestion, renovation
      t.string :investment_region
      t.string :project_type                        # neuf, renovation, transformation
      t.integer :project_size                       # nombre de logements
      t.decimal :investment_budget, precision: 12, scale: 2
      t.string :certifications_targeted            # PEB, BREEAM, etc.

      # Champs spécialisés Entreprises Commerciales
      t.string :business_sector
      t.string :company_size                        # TPE, PME, grande_entreprise
      t.string :activity_region
      t.string :investment_type                     # equipements, batiments, rd, formation
      t.decimal :business_budget, precision: 12, scale: 2
      t.string :business_objectives                 # croissance, transition_eco, digitalisation
      t.string :company_status                      # startup, etablie

      t.timestamps
    end

    # Index pour optimiser les requêtes
    add_index :contact_submissions, :type
    add_index :contact_submissions, :region
    add_index :contact_submissions, :status
    add_index :contact_submissions, :submitted_at
    add_index :contact_submissions, [:type, :region]
    add_index :contact_submissions, [:status, :submitted_at]
  end
end

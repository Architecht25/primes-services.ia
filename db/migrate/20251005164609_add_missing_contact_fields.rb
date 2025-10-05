class AddMissingContactFields < ActiveRecord::Migration[8.0]
  def change
    # Ajouter les champs manquants pour les formulaires
    add_column :contact_submissions, :address, :text
    add_column :contact_submissions, :city, :string
    add_column :contact_submissions, :postal_code, :string
    add_column :contact_submissions, :surface_area, :integer
    add_column :contact_submissions, :timeline, :string
    add_column :contact_submissions, :priority, :string
    add_column :contact_submissions, :current_heating, :string
    add_column :contact_submissions, :income_range, :string
    add_column :contact_submissions, :project_scale, :string
    add_column :contact_submissions, :target_market, :string
    
    # Ajouter index pour les nouveaux champs
    add_index :contact_submissions, :postal_code
    add_index :contact_submissions, :city
  end
end

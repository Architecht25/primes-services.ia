class AddFieldsForAcpAndEntrepriseContacts < ActiveRecord::Migration[8.0]
  def change
    # Champs pour AcpContact
    add_column :contact_submissions, :number_of_units, :integer
    add_column :contact_submissions, :building_type, :string
    add_column :contact_submissions, :building_work_type, :string
    add_column :contact_submissions, :voted_budget, :decimal
    add_column :contact_submissions, :work_urgency, :string

    # Champs pour EntrepriseImmoContact et EntrepriseCommContact
    add_column :contact_submissions, :business_activity, :string
    add_column :contact_submissions, :investment_region, :string
    add_column :contact_submissions, :project_scale, :string
    add_column :contact_submissions, :target_market, :string

    # Champ spécifique à EntrepriseCommContact
    add_column :contact_submissions, :company_size, :string
  end
end

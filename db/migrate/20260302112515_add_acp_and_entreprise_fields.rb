class AddAcpAndEntrepriseFields < ActiveRecord::Migration[8.0]
  def change
    # Champs pour AcpContact
    add_column :contact_submissions, :number_of_units, :integer unless column_exists?(:contact_submissions, :number_of_units)
    add_column :contact_submissions, :building_type, :string unless column_exists?(:contact_submissions, :building_type)
    add_column :contact_submissions, :building_work_type, :string unless column_exists?(:contact_submissions, :building_work_type)
    add_column :contact_submissions, :voted_budget, :decimal unless column_exists?(:contact_submissions, :voted_budget)
    add_column :contact_submissions, :work_urgency, :string unless column_exists?(:contact_submissions, :work_urgency)

    # Champs pour EntrepriseImmoContact et EntrepriseCommContact
    add_column :contact_submissions, :business_activity, :string unless column_exists?(:contact_submissions, :business_activity)
    add_column :contact_submissions, :investment_region, :string unless column_exists?(:contact_submissions, :investment_region)

    # Champ spécifique à EntrepriseCommContact
    add_column :contact_submissions, :company_size, :string unless column_exists?(:contact_submissions, :company_size)

    # Note: Les colonnes suivantes existent déjà dans la table:
    # - project_scale
    # - target_market
    # - construction_year
    # - estimated_budget
    # - realization_deadline
    # - timeline
  end
end

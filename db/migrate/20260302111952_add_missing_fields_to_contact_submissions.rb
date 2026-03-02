class AddMissingFieldsToContactSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_column :contact_submissions, :construction_year, :integer
    add_column :contact_submissions, :estimated_budget, :decimal
    add_column :contact_submissions, :realization_deadline, :string
  end
end

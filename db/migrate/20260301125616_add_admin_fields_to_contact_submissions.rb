class AddAdminFieldsToContactSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_column :contact_submissions, :read_at, :datetime
    add_column :contact_submissions, :ip_address, :string
    add_column :contact_submissions, :user_agent, :text
    add_column :contact_submissions, :first_name, :string
    add_column :contact_submissions, :last_name, :string
    add_column :contact_submissions, :property_type, :string
    add_column :contact_submissions, :work_type, :string
    add_column :contact_submissions, :submission_type, :string
  end
end

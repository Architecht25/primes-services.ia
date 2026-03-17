class AddSyndicContactToContactSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_column :contact_submissions, :syndic_contact, :text
  end
end

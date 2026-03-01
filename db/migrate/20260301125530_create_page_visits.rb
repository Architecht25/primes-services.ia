class CreatePageVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :page_visits do |t|
      t.string :visitor_id
      t.string :page_path
      t.string :referrer
      t.text :user_agent
      t.string :ip_address
      t.string :user_region
      t.string :device_type
      t.string :session_id
      t.integer :time_on_page

      t.timestamps
    end
  end
end

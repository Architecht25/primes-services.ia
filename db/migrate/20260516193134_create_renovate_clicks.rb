class CreateRenovateClicks < ActiveRecord::Migration[8.0]
  def change
    create_table :renovate_clicks do |t|
      t.string  :profile,        null: false, default: 'general'
      t.string  :region
      t.string  :source_page
      t.string  :element
      t.string  :session_id
      t.string  :ip_address
      t.string  :user_agent
      t.string  :referrer
      t.string  :redirect_url
      t.string  :event_type,     null: false, default: 'click'
      t.jsonb   :metadata,       null: false, default: {}

      t.timestamps
    end

    add_index :renovate_clicks, :profile
    add_index :renovate_clicks, :region
    add_index :renovate_clicks, :event_type
    add_index :renovate_clicks, :created_at
  end
end

class CreateSecurityLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :security_logs do |t|
      t.string :event_type
      t.string :severity
      t.string :ip_address
      t.text :user_agent
      t.jsonb :details
      t.text :description

      t.timestamps
    end
  end
end

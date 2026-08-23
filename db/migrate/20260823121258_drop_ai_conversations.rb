class DropAiConversations < ActiveRecord::Migration[8.0]
  def up
    drop_table :ai_conversations
  end

  def down
    create_table :ai_conversations do |t|
      t.string "session_id", null: false
      t.string "user_type"
      t.string "user_region"
      t.text "messages"
      t.string "status", default: "active"
      t.json "metadata"
      t.timestamps

      t.index ["created_at"]
      t.index ["session_id", "status"]
      t.index ["session_id"]
      t.index ["status"]
      t.index ["user_region"]
      t.index ["user_type", "user_region"]
      t.index ["user_type"]
    end
  end
end

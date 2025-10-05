class CreateAiConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_conversations do |t|
      t.string :session_id, null: false
      t.string :user_type                    # particulier, acp, entreprise_immo, entreprise_comm
      t.string :user_region                  # wallonie, flandre, bruxelles
      t.text :messages                       # JSON des messages de la conversation
      t.string :status, default: 'active'   # active, completed, archived
      t.json :metadata                       # Données additionnelles (IP, user_agent, etc.)

      t.timestamps
    end

    # Index pour optimiser les requêtes
    add_index :ai_conversations, :session_id
    add_index :ai_conversations, :user_type
    add_index :ai_conversations, :user_region
    add_index :ai_conversations, :status
    add_index :ai_conversations, :created_at
    
    # Index composé pour les requêtes courantes
    add_index :ai_conversations, [:session_id, :status]
    add_index :ai_conversations, [:user_type, :user_region]
  end
end

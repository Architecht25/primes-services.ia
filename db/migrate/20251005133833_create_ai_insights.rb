class CreateAiInsights < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_insights do |t|
      t.string :insight_type, null: false
      t.json :content
      t.decimal :confidence_score, precision: 5, scale: 4, default: 0.0
      t.json :input_data
      t.string :ai_model, default: 'gpt-4'
      t.json :ai_metadata
      t.string :status, null: false, default: 'pending'
      t.datetime :started_at
      t.datetime :completed_at
      t.text :error_message
      t.references :prime, foreign_key: true
      t.references :calculation, foreign_key: true
      t.json :metadata

      t.timestamps
    end

    add_index :ai_insights, :insight_type
    add_index :ai_insights, :status
    add_index :ai_insights, :confidence_score
    add_index :ai_insights, :created_at
    add_index :ai_insights, [:status, :insight_type]
  end
end

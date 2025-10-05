class CreateCalculations < ActiveRecord::Migration[8.0]
  def change
    create_table :calculations do |t|
      t.string :calculation_type, null: false
      t.json :input_params, null: false
      t.json :result
      t.string :status, null: false, default: 'pending'
      t.datetime :started_at
      t.datetime :completed_at
      t.text :error_message
      t.references :prime, foreign_key: true

      t.timestamps
    end

    add_index :calculations, :calculation_type
    add_index :calculations, :status
    add_index :calculations, :created_at
    add_index :calculations, [:status, :calculation_type]
  end
end

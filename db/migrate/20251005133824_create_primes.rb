class CreatePrimes < ActiveRecord::Migration[8.0]
  def change
    create_table :primes do |t|
      t.bigint :value, null: false
      t.integer :position, null: false

      t.timestamps
    end

    add_index :primes, :value, unique: true
    add_index :primes, :position, unique: true
    add_index :primes, :created_at
  end
end

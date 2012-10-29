class CreateAircrafts < ActiveRecord::Migration
  def change
    create_table :aircrafts do |t|
      t.integer :identifier_id
      t.integer :model_id
      t.integer :year_manufactured
      t.integer :transponder_code
    end

    add_index :aircrafts, [:identifier_id, :model_id], :unique => true

    add_foreign_key :aircrafts, :identifiers
    add_foreign_key :aircrafts, :models
  end
end

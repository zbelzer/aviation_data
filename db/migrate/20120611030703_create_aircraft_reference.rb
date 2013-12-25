class CreateAircraftReference < ActiveRecord::Migration
  def change
    create_table :aircraft_reference do |t|
      t.string :code
      t.string :manufacturer_name
      t.string :model_name
      t.integer :aircraft_type_id
      t.integer :engine_type_id
      t.integer :aircraft_category_id
      t.integer :builder_certification_id
      t.integer :engines
      t.integer :seats
      t.string :weight
      t.integer :cruising_speed
    end
  end
end

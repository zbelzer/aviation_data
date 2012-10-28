class CreateAircraftReference < ActiveRecord::Migration
  def change
    create_table :aircraft_reference do |t|
      t.string :code
      t.string :manufacturer_name
      t.string :model_name
      t.string :aircraft_type
      t.string :engine_type
      t.string :aircraft_category_code
      t.string :builder_certification_code
      t.integer :engines
      t.integer :seats
      t.string :weight
      t.integer :cruising_speed
    end
  end
end

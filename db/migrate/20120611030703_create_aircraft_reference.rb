class CreateAircraftReference < ActiveRecord::Migration
  def change
    create_table :aircraft_reference do |t|
      t.string :aircraft_model_code
      t.string :manufacturer
      t.string :model_name
      t.string :type_aircraft
      t.string :type_engine
      t.string :aircraft_category_code
      t.string :builder_certification_code
      t.integer :engines
      t.integer :seats
      t.string :weight
      t.integer :cruising_speed
    end
  end
end

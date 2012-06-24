class CreateModel < ActiveRecord::Migration
  def change
    create_table :models do |t|
      t.string :code
      t.integer :manufacturer_id
      t.integer :model_id
      t.string :type_aircraft
      t.string :type_engine
      t.string :aircraft_category_code
      t.string :builder_certification_code
      t.integer :engines
      t.integer :seats
      t.integer :weight_id
      t.integer :cruising_speed
    end
  end
end

class CreateModel < ActiveRecord::Migration
  def change
    create_table :models do |t|
      t.string :code

      t.integer :manufacturer_id
      t.integer :model_name_id
      t.integer :aircraft_type_id
      t.integer :engine_type_id

      t.string :aircraft_category_code
      t.string :builder_certification_code
      t.integer :engines
      t.integer :seats
      t.integer :weight_id
      t.integer :cruising_speed
    end

    add_index :models, :code
  end
end

class CreateModels < ActiveRecord::Migration
  def change
    create_table :models do |t|
      t.string :code

      t.integer :manufacturer_name_id
      t.integer :model_name_id
      t.integer :aircraft_type_id
      t.integer :engine_type_id
      t.integer :aircraft_category_id
      t.integer :builder_certification_id

      t.integer :engines
      t.integer :seats
      t.integer :weight_id
      t.integer :cruising_speed
    end

    add_index :models, :code

    add_foreign_key :models, :manufacturer_names
    add_foreign_key :models, :model_names
    add_foreign_key :models, :aircraft_types
    add_foreign_key :models, :aircraft_categories
    add_foreign_key :models, :builder_certifications
    add_foreign_key :models, :engine_types
  end
end

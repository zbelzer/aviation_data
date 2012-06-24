class CreateManufacturerName < ActiveRecord::Migration
  def change
    create_enum :manufacturer_names, :name_length => 50
  end
end

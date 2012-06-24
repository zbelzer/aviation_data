class CreateCities < ActiveRecord::Migration
  def change
    create_enum :cities, :name_length => 50
  end
end

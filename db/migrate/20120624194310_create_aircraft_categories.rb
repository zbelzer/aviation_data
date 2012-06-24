class CreateAircraftCategories < ActiveRecord::Migration
  def change
    create_enum :aircraft_categories, :name_length => 50, :description => true
  end
end

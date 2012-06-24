class CreateAircraftTypes < ActiveRecord::Migration
  def change
    create_enum :aircraft_types, :name_length => 50, :description => true
  end
end

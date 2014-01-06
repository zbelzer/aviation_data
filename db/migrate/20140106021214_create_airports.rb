class CreateAirports < ActiveRecord::Migration
  def change
    create_table :airports do |t|
      t.string :name
      t.string :icao
      t.string :iata
      t.decimal :latitude
      t.decimal :longitude
      t.string :magnetic_variance
      t.integer :elevation
      t.integer :country_id
      t.string :time_zone
    end
  end
end

class CreateAirmen < ActiveRecord::Migration
  def change
    create_table :airmen do |t|
      t.string :unique_number
      t.string :first_name
      t.string :last_name
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :region
      t.string :medical_class
      t.date :medical_date
      t.date :medical_expiration_date
    end
  end
end

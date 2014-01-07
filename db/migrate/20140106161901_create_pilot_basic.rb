class CreatePilotBasic < ActiveRecord::Migration
  def change
    create_table :pilot_basic do |t|
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
      t.string :medical_date
      t.string :medical_expiration_date
      t.string :dummy
    end
  end
end

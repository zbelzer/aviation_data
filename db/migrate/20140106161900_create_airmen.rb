class CreateAirmen < ActiveRecord::Migration
  def change
    create_table :airmen do |t|
      t.string :unique_number
      t.string :first_name
      t.string :last_name
      t.integer :medical_class
      t.date :medical_date
      t.date :medical_expiration_date
    end

    add_index :airmen, :unique_number, :unique => true
  end
end

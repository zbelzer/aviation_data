class CreateMasterTable < ActiveRecord::Migration
  def change
    create_table :master do |t|
      t.string :identifier
      t.string :serial_number
      t.string :aircraft_model_code
      t.integer :engine_mode_code
      t.integer :year_manufactured
      t.integer :type_registrant
      t.string :registrant_name
      t.string :street1
      t.string :street2
      t.string :registrant_city
      t.string :registrant_state
      t.string :registrant_zip
      t.string :registrant_region
      t.string :county_mail
      t.string :country_mail
      t.date :last_activity_date
      t.date :certificate_issue_date
      t.string :approved_operation_codes
      t.integer :type_aircraft
      t.integer :type_engine
      t.string :status_code
      t.integer :transponder_code
      t.string :fractional_ownership
      t.date :airworthiness_date
      t.string :owner_one
      t.string :owner_two
      t.string :owner_three
      t.string :owner_four
      t.string :owner_five
      t.date :expiration_date
      t.integer :unique_id
    end

    add_index :master, :identifier
    add_index :master, :serial_number
    add_index :master, :aircraft_model_code
  end
end

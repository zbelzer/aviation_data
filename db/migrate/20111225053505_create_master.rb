class CreateMaster < ActiveRecord::Migration
  def change
    create_table :master do |t|
      t.string :identifier
      t.string :serial_number
      t.string :aircraft_model_code
      t.string :engine_mode_code
      t.string :year_manufactured
      t.string :type_registrant
      t.string :registrant_name
      t.string :street1
      t.string :street2
      t.string :registrant_city
      t.string :registrant_state
      t.string :registrant_zip
      t.string :registrant_region
      t.string :county_mail
      t.string :country_mail
      t.string :last_activity_date
      t.string :certificate_issue_date
      t.string :approved_operation_codes
      t.string :type_aircraft
      t.string :type_engine
      t.string :status_code
      t.string :transponder_code
      t.string :fractional_ownership
      t.string :airworthiness_date
      t.string :owner_one
      t.string :owner_two
      t.string :owner_three
      t.string :owner_four
      t.string :owner_five
      t.string :expiration_date
      t.string :unique_id
      t.string :kit_manufacturer
      t.string :kit_model
      t.string :mode_s_code_hex
    end

    add_index :master, :identifier
    add_index :master, :serial_number
    add_index :master, :aircraft_model_code
  end
end

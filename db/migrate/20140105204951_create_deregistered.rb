class CreateDeregistered < ActiveRecord::Migration
  def change
    create_table :deregistered do |t|
      t.string :identifier
      t.string :serial_number
      t.string :aircraft_model_code
      t.string :status_code
      t.string :name
      t.string :address_1
      t.string :address_2
      t.string :city_mail
      t.string :state_abbrev_mail
      t.string :zip_code_mail
      t.integer :engine_mode_code
      t.integer :year_manufactured
      t.string :certification
      t.string :region
      t.string :county_mail
      t.string :country_mail
      t.date :airworthiness_date
      t.date :cancel_date
      t.string :mode_s_code
      t.string :indicator_group
      t.string :exp_country
      t.date :last_act_date
      t.date :cert_issue_date
      t.string :street_physical
      t.string :street2_physical
      t.string :city_physical
      t.string :state_abbrev_physical
      t.string :zip_code_physical
      t.string :county_physical
      t.string :country_physical
      t.string :owner_1
      t.string :owner_2
      t.string :owner_3
      t.string :owner_4
      t.string :owner_5
    end
  end
end

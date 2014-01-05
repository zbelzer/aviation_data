class CreateDealers < ActiveRecord::Migration
  def change
    create_table :dealers do |t|
      t.string :certificate_number
      t.string :ownership
      t.string :certificate_date
      t.string :expiration_date
      t.string :expiration_flag
      t.string :certificate_issue_count
      t.string :name
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state_abbrev
      t.string :zip_code
      t.string :other_names_count
      t.string :other_names_1
      t.string :other_names_2
      t.string :other_names_3
      t.string :other_names_4
      t.string :other_names_5
      t.string :other_names_6
      t.string :other_names_7
      t.string :other_names_8
      t.string :other_names_9
      t.string :other_names_10
      t.string :other_names_11
      t.string :other_names_12
      t.string :other_names_13
      t.string :other_names_14
      t.string :other_names_15
      t.string :other_names_16
      t.string :other_names_17
      t.string :other_names_18
      t.string :other_names_19
      t.string :other_names_20
      t.string :other_names_21
      t.string :other_names_22
      t.string :other_names_23
      t.string :other_names_24
      t.string :other_names_25
    end
  end
end

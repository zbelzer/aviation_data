class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
    t.string :unique_number
    t.string :first_name
    t.string :last_name
    t.string :certificate_type_id
    t.string :level
    t.date :expiration_date
    t.string :rating1
    t.string :rating2
    t.string :rating3
    t.string :rating4
    t.string :rating5
    t.string :rating6
    t.string :rating7
    t.string :rating8
    t.string :rating9
    t.string :rating10
    t.string :rating11
    end
  end
end

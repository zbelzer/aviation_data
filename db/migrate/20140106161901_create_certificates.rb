class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.integer :airman_id
      t.integer :certificate_type_id
      t.string :level
      t.date :expiration_date
    end

    add_foreign_key :certificates, :airmen
    add_foreign_key :certificates, :certificate_types
  end
end

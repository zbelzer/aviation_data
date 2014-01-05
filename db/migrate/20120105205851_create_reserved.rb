class CreateReserved < ActiveRecord::Migration
  def change
    create_table :reserved do |t|
      t.string :identifier
      t.string :registrant
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :zip
      t.string :code
      t.string :reserved_date
      t.string :tr
      t.string :expirtation_date
      t.string :identifier_change
    end
  end
end

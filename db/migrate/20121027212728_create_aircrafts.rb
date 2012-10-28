class CreateAircrafts < ActiveRecord::Migration
  def change
    create_table :aircrafts do |t|
      t.integer :identifier_id
      t.integer :model_id
    end
  end
end

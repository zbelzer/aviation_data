class CreateEngines < ActiveRecord::Migration
  def change
    create_table :engines do |t|
      t.string :code
      t.string :manufacturer
      t.string :model
      t.string :type
      t.string :horsepower
      t.string :thrust
    end
  end
end

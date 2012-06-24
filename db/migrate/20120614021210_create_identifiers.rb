class CreateIdentifiers < ActiveRecord::Migration
  def change
    create_table :identifiers do |t|
      t.integer :identifier_type_id
      t.string :code
      t.date :started_at
      t.date :ended_at
    end

    add_index :identifiers, :code, :unique => true
  end
end

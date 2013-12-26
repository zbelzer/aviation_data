class CreateIdentifiers < ActiveRecord::Migration
  def change
    create_table :identifiers do |t|
      t.integer :identifier_type_id
      t.string :code
    end

    add_index :identifiers, :code, :unique => true

    add_foreign_key :identifiers, :identifier_types
  end
end

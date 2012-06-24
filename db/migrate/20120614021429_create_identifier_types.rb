class CreateIdentifierTypes < ActiveRecord::Migration
  def change
    create_enum :identifier_types, :name_length => 50, :description => true
  end
end

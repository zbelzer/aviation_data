class CreateCountries < ActiveRecord::Migration
  def change
    create_enum :countries, :name_length => 50, :description => true
  end
end

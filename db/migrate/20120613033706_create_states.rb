class CreateStates < ActiveRecord::Migration
  def change
    create_enum :states, :name_length => 50, :description => true
  end
end

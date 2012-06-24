class CreateWeights < ActiveRecord::Migration
  def change
    create_enum :weights, :name_length => 50, :description => true
  end
end

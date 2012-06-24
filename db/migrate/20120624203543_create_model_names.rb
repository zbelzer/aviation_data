class CreateModelNames < ActiveRecord::Migration
  def change
    create_enum :model_names, :name_length => 50, :description => true
  end
end

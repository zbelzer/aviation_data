class CreateEngineTypes < ActiveRecord::Migration
  def change
    create_enum :engine_types, :name_length => 50, :description => true
  end
end

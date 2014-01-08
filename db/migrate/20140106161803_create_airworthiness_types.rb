class CreateAirworthinessTypes < ActiveRecord::Migration
  def change
    create_enum :airworthiness_type, :description => true
  end
end

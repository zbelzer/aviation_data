class AddIndexToAsOf < ActiveRecord::Migration
  def change
    add_index :aircrafts, :as_of
  end
end

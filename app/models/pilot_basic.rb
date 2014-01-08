class PilotBasic < ActiveRecord::Base
  self.table_name = 'pilot_basic'

  scope :missing_airmen, lambda {
    select("pilot_basic.*").
    joins("LEFT JOIN airmen ON pilot_basic.unique_number = airmen.unique_number").
    where(:airmen => {:id => nil}).
    order(:id)
  }
end

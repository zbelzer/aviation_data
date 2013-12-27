class AircraftReference < ActiveRecord::Base
  set_table_name 'aircraft_reference'

  has_enumerated :aircraft_type
  has_enumerated :engine_type
  has_enumerated :aircraft_category
  has_enumerated :builder_certification

  scope :missing_models, lambda {
    joins("LEFT JOIN models ON aircraft_reference.code = models.code").
    where(:models => {:code => nil})
  }
end

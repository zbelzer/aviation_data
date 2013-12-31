class Master < ActiveRecord::Base
  set_table_name 'master'

  scope :missing_aircraft, lambda {
    select("master.*, identifiers.id AS identifier_id, models.id AS model_id").
    joins("JOIN identifiers ON master.identifier = identifiers.code").
    joins("JOIN models ON master.aircraft_model_code = models.code").
    joins("LEFT JOIN aircrafts ON (aircrafts.identifier_id = identifiers.id AND aircrafts.model_id = models.id)").
    where(:aircrafts => {:id => nil})
  }

  scope :missing_identifiers, lambda {
    joins("LEFT JOIN identifiers ON master.identifier = identifiers.code").
    where(:identifiers => {:code => nil})
  }
end

class Master < ActiveRecord::Base
  set_table_name 'master'

  scope :missing_aircraft, lambda {
    unique_sql = Master.
      select("master.id").
      joins("JOIN identifiers ON master.identifier = identifiers.code").
      joins("JOIN models ON master.aircraft_model_code = models.code").
      joins("LEFT JOIN aircrafts ON (aircrafts.identifier_id = identifiers.id AND aircrafts.model_id = models.id)").
      where(:aircrafts => {:id => nil}).to_sql

    where("id IN (#{unique_sql})").order(:id)
  }

  scope :missing_identifiers, lambda {
    joins("LEFT JOIN identifiers ON master.identifier = identifiers.code").
    where(:identifiers => {:code => nil})
  }
end

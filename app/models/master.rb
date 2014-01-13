# Records that indicate the pairings between identifiers (N-Numbers), engines
# and models.
#
# Per documentation:
# "Contains the records of all U.S. Civil Aircraft maintained by the FAA, Civil
# Aviation Registry, Aircraft Registration Branch, AFS-750"
class Master < ActiveRecord::Base
  self.table_name = 'master'

  scope :missing_aircraft, lambda {
    select("master.*, identifiers.id AS identifier_id, models.id AS model_id").
    joins("JOIN identifiers ON master.identifier = identifiers.code").
    joins("JOIN models ON master.aircraft_model_code = models.code").
    joins("LEFT JOIN aircrafts ON (aircrafts.identifier_id = identifiers.id AND aircrafts.model_id = models.id)").
    where(:aircrafts => {:id => nil}).
    order(:id)
  }

  scope :missing_identifiers, lambda {
    select("master.*").
    joins("LEFT JOIN identifiers ON master.identifier = identifiers.code").
    where(:identifiers => {:code => nil}).
    order(:id)
  }
end

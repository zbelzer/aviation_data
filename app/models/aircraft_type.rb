# Aircraft type information imported from the FAA.
class AircraftType < ActiveRecord::Base
  acts_as_enumerated
end

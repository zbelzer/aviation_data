# Aircraft categories imported from the FAA.
class AircraftCategory < ActiveRecord::Base
  acts_as_enumerated
end

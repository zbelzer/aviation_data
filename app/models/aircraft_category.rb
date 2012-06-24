class AircraftCategory < ActiveRecord::Base
  CODE_MAP = {
    1 => :land,
    2 => :sea,
    3 => :amphibian
  }
  acts_as_enumerated
end

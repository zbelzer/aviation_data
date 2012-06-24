class AircraftEngineType < ActiveRecord::Base
  CODE_MAP = {
    0 => :none,
    1 => :piston,
    2 => :turboprop,
    3 => :turboshaft,
    4 => :turbojet,
    5 => :turbofan,
    6 => :ramjet,
    7 => :two_cycle,
    8 => :four_cycle
  }
  acts_as_enumerated
end

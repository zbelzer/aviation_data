class AircraftType < ActiveRecord::Base
  CODE_MAP = {
    '1' => :glider,
    '2' => :balloon,
    '3' => :blimp,
    '4' => :fixed_wing_single_engine,
    '5' => :fixed_wing_multi_engine,
    '6' => :rotorcraft,
    '7' => :weight_shift_control,
    '8' => :powered_parachute,
    '9' => :gyroplane
  }
  acts_as_enumerated
end

class AirworthinessType < ActiveRecord::Base
  CODE_MAP = {
    '1' => 'standard',
    '2' => 'limited',
    '3' => 'restricted',
    '4' => 'experimental',
    '5' => 'provisional',
    '6' => 'multiple',
    '7' => 'primary',
    '8' => 'special_flight_permit',
    '9' => 'light_sport'
  }
  acts_as_enumerated
end

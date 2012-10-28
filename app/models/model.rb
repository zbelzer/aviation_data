class Model < ActiveRecord::Base
  has_enumerated :manufacturer_name
  has_enumerated :model_name
  has_enumerated :aircraft_type
  has_enumerated :engine_type
  has_enumerated :weight
end

# Model information imported from the FAA.
class Model < ActiveRecord::Base
  has_enumerated :manufacturer_name
  has_enumerated :model_name
  has_enumerated :aircraft_type
  has_enumerated :engine_type
  has_enumerated :weight
  has_enumerated :aircraft_category
  has_enumerated :builder_certification

  # Alias for ActiveAdmin.
  # @return [String]
  def name
    code
  end
end

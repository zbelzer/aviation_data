require 'roar/decorator'
require 'roar/representer/json'

class AircraftRepresenter < Roar::Decorator
  include Roar::Representer::JSON

  property :code, as: :identifier

  property :model_name
  property :manufacturer_name
  property :aircraft_type
  property :aircraft_category
  property :engine_type
  property :engines
  property :weight
  property :seats
  property :builder_certification
  property :cruising_speed
  property :as_of
end


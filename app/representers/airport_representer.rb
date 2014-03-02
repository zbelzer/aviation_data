require 'roar/decorator'
require 'roar/representer/json'

class AirportRepresenter < Roar::Decorator
  include Roar::Representer::JSON

  property :name
  property :iata
  property :icao
end


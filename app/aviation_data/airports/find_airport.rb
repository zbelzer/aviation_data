# Find an Airport in the database.
class AviationData::Airports::FindAirport
  include Wisper::Publisher

  # @param options [Hash]
  # @option options [String] :identifier
  def initialize(options)
    @identifier = options[:identifier]
  end

  # Execute the search and run callbacks.
  def run
    if airport = find_airport
      publish(:success, airport)
    else
      publish(:failure)
    end
  end

  # Find an Airport matching icao or iata codes.
  #
  # @return [Aircraft]
  def find_airport
    Airport.
      where("icao = ? OR iata = ?", @identifier, @identifier).
      first
  end
end

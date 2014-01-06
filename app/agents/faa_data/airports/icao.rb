require 'csv'

# The 'icao' airport database format.
module FaaData::Airports::Icao
  # Headers of the ICAO format.
  HEADERS = %w(icao iata name)

  # Import airports from the icao database format.
  #
  # @param [String, Pathname] file_path
  # @return [Array<Airport>]
  def self.import(file_path)
    airports = []

    CSV.foreach(file_path, :headers => HEADERS, :converters => :all) do |row|
      attributes = {
        :name => row["name"],
        :iata => row["iata"],
        :icao => row["icao"],
      }

      airport = Airport.new(attributes)
      airport.save(:validate => false)
      airports << airport
    end

    airports
  end
end

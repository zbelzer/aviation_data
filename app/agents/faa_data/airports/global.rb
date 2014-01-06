require 'csv'

# The 'global' airport database format.
module FaaData::Airports::Global
  # Headers of the global format.
  HEADERS = %w(icao iata name address country lat_deg lat_min lat_sec lat_dir lon_deg lon_min lon_sec lon_dir elevation) 

  # Import airports from the global database format.
  #
  # @param [String, Pathname] file_path
  # @return [Array<Airport>]
  def self.import(file_path)
    airports = []

    countries = Country.all.inject({}) do |memo, country|
      memo[country.description] = country.id
      memo
    end

    CSV.foreach(file_path, :headers => HEADERS, :converters => :all, :col_sep => ':') do |row|
      latitude = make_coord_global("lat", row)
      longitude = make_coord_global("lon", row)

      attributes = {
        :name      => row["name"],
        :iata      => row["iata"],
        :icao      => row["icao"],
        :longitude => longitude,
        :latitude  => latitude,
        :country_id => countries[row["country"]],
        :elevation => row["elevation"],
      }

      airport = Airport.new(attributes)
      airport.save(:validate => false)
      airports << airport
    end

    airports
  end

  # Converts latitude and longitude to appropriate decimals.
  def self.make_coord_global(type, row)
    dir = row["#{type}_dir"]
    dir = dir == "U" ? "W" : dir

    "#{row["#{type}_deg"].to_f + row["#{type}_min"].to_f / 60.0 + row["#{type}_sec"].to_f / 3600.0}#{dir}"
  end
end

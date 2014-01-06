require 'csv'
# The 'global' airport database format.
module FaaData::Airports::Faa
  # Headers of the FAA format.
  HEADERS = %w(dummy code dummy latitude longitude magnetic_variance elevation dummy time_zone dummy name dummy)

  # Import airports from the faa database format.
  #
  # @param [String, Pathname] file_path
  # @return [Array<Airport>]
  def self.import(file_path)
    airports = []

    CSV.foreach(file_path, :headers => HEADERS, :converters => :all) do |row|
      attributes = {
        :name              => row["name"],
        :longitude         => make_coord_faa(row["longitude"]),
        :latitude          => make_coord_faa(row["latitude"]),
        :magnetic_variance => row["magnetic_variance"],
        :elevation         => row["elevation"],
      }

      code = row["code"]
      if code =~ /^k/i
        attributes.update(:icao => code)
      else
        attributes.update(:iata => code)
      end

      airport = Airport.new(attributes)
      airport.save(:validate => false)
      airports << airport
    end

    airports
  end

  # Converts latitude and longitude to appropriate decimals.
  def self.make_coord_faa(data)
    data =~ /(\w)(\d+)/
    dir, coord = $1, $2

    if dir =~ /n|s/i
      coord =~ /(\d{2})(\d{2})(\d{2})/
    else
      coord =~ /(\d{3})(\d{2})(\d{2})/
    end

    "#{$1.to_f + $2.to_f / 60.0 + $3.to_f / 3600.0}#{dir}"
  end
end

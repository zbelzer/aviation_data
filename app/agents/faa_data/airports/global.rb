# The 'global' airport database format.
module FaaData::Airports::Global
  # Import airports from the global database format.
  #
  # @param [String, Pathname] file_path
  # @return [Array<Airport>]
  def self.import(file_path)
    headers = %w(icao iata name address country lat_deg lat_min lat_sec lat_dir lon_deg lon_min lon_sec lon_dir elevation) 
    airports = []

    File.foreach(file_path) do |line|
      values = line.split(":")
      row = Hash[*headers.zip(values).flatten(1)]

      latitude = make_coord_global("lat", row)
      longitude = make_coord_global("lon", row)

      data = row.reject {|x| x.first =~ /lat|lon/ || x.last =~ /N\/A/}
      icao = data.delete("icao")

      data.merge!("latitude" => latitude, "longitude" => longitude)

      airports << Airport.create!(:icao => icao)
    end
  end

  # Converts latitude and longitude to appropriate decimals.
  def self.make_coord_global(type, row)
    dir = row["#{type}_dir"]
    dir = dir == "U" ? "W" : dir

    "#{row["#{type}_deg"].to_f + row["#{type}_min"].to_f / 60.0 + row["#{type}_sec"].to_f / 3600.0}#{dir}"
  end
end

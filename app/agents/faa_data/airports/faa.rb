# The 'global' airport database format.
module FaaData::Airports::Faa
  # Import airports from the faa database format.
  #
  # @param [String, Pathname] file_path
  # @return [Array<Airport>]
  def self.import(file_path)
    headers = %w(dummy code dummy latitude longitude magnetic_variance elevation dummy time_zone dummy name dummy)
    airports = []

    seen_header = false

    File.foreach(file_path) do |row|
      if !seen_header && row["name"] == "NAME"
        seen_header = true
        next
      end
      values = row.split(",")
      row = Hash[*headers.zip(values).flatten(1)]

      data = row.reject {|x| x.first =~ /dummy/}
      code = data.delete("code")
      data.merge!("longitude" => Airport.make_coord_faa(data["longitude"]))
      data.merge!("latitude" => Airport.make_coord_faa(data["latitude"]))

      if code =~ /^k/i
        airports << Airport.create!(:icao => code)
      else
        airports << Airport.create!(:iata => code)
      end
    end
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

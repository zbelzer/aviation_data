# The 'icao' airport database format.
module FaaData::Airports::Icao
  # Import airports from the icao database format.
  #
  # @param [String, Pathname] file_path
  # @return [Array<Airport>]
  def self.import(file_path)
    headers = %w(icao iata name)
    airports = []

    File.foreach(file_path) do |row|
      count += 1
      values = row.split(",").map {|v| v[-1...-1]}
      row = Hash[*headers.zip(values).flatten(1)]

      icao = row.delete("icao")
      airports << Airport.create!(:icao => icao)
    end

  end
end

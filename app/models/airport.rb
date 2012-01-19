class Airport
  include MongoMapper::Document

  key :icao, String
  key :iata, String
  key :longitude, Float
  key :latitude, Float

  ensure_index [[:icao, 1], [:iata, 1]]
  
  def self.make_coord_global(type, row)
    dir = row["#{type}_dir"]
    dir = dir == "U" ? "W" : dir

    "#{row["#{type}_deg"].to_f + row["#{type}_min"].to_f / 60.0 + row["#{type}_sec"].to_f / 3600.0}#{dir}"
  end

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

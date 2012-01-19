require 'aviation_data'

namespace :airports do
  desc "Clears and imports all current airport data"
  task :import => [:clear, 'import:icao', 'import:faa', 'import:global']

  namespace :import do
    # Global has the best names
    task :global => :environment do
      file_path = "#{AviationData::AIRPORT_PATH}/GlobalAirportDatabase/GlobalAirportDatabase.txt"
      headers = %w(icao iata name address country lat_deg lat_min lat_sec lat_dir lon_deg lon_min lon_sec lon_dir elevation) 
      count = 0

      File.foreach(file_path) do |line|
        values = line.split(":")
        row = Hash[*headers.zip(values).flatten(1)]
        count += 1

        latitude = Airport.make_coord_global("lat", row)
        longitude = Airport.make_coord_global("lon", row)

        data = row.reject {|x| x.first =~ /lat|lon/ || x.last =~ /N\/A/}
        icao = data.delete("icao")

        data.merge!("latitude" => latitude, "longitude" => longitude)

        Airport.create_or_update({"icao" => icao}, {"$set" => data})
      end

      puts "Imported or updated #{count} airports from #{File.basename(file_path)}"
    end

    task :faa => :environment do
      file_path = "#{AviationData::AIRPORT_PATH}/airports.csv"
      headers = %w(dummy code dummy latitude longitude magnetic_variance elevation dummy time_zone dummy name dummy)
      count = 0

      seen_header = false

      File.foreach(file_path) do |row|
        if !seen_header && row["name"] == "NAME"
          seen_header = true
          next
        end
        values = row.split(",")
        row = Hash[*headers.zip(values).flatten(1)]

        count += 1

        data = row.reject {|x| x.first =~ /dummy/}
        code = data.delete("code")
        data.merge!("longitude" => Airport.make_coord_faa(data["longitude"]))
        data.merge!("latitude" => Airport.make_coord_faa(data["latitude"]))

        if code =~ /^k/i
          Airport.create_or_update({"icao" => code}, {"$set" => data})
        else
          Airport.create_or_update({"iata" => code}, {"$set" => data})
        end
      end

      puts "Imported or updated #{count} airports from #{File.basename(file_path)}"
    end

    task :icao => :environment do
      file_path = "#{AviationData::AIRPORT_PATH}/ICAO.airports.csv"
      headers = %w(icao iata name)
      count = 0

      File.foreach(file_path) do |row|
        count += 1
        values = row.split(",").map {|v| v[-1...-1]}
        row = Hash[*headers.zip(values).flatten(1)]

        icao = row.delete("icao")
        Airport.create_or_update({"icao" => icao}, {"$set" => row})
      end

      puts "Imported or updated #{count} airports from #{File.basename(file_path)}"
    end
  end

  task :clear => :environment do
    AviationData::OutputUtilities.run_step "Clearing current airports collection" do
      Airport.delete_all
    end
  end
end

namespace :airports do
  desc "Clears and imports all current airport data"
  task :import => [:clear, 'import:icao', 'import:faa', 'import:global']

  namespace :import do
    # Global has the best names
    task :global => :environment do
      file_path = Airports.root.join("/GlobalAirportDatabase/GlobalAirportDatabase.txt")
      airports = FaaData::Airports::Global.import(file_path)
      puts "Imported or updated #{airports.size} airports from #{File.basename(file_path)}"
    end

    task :faa => :environment do
      file_path = Airports.root.join("airports.csv")
      airports = FaaData::Airports::Faa.import(file_path)
      puts "Imported or updated #{airports.size} airports from #{File.basename(file_path)}"
    end

    task :icao => :environment do
      file_path = Airports.root.join("ICAO.airports.csv")
      airports = FaaData::Airports::Icao.import(file_path)
      puts "Imported or updated #{airports.size} airports from #{File.basename(file_path)}"
    end
  end

  task :clear => :environment do
    AviationData::OutputUtilities.run_step "Clearing current airports collection" do
      Airport.delete_all
    end
  end
end

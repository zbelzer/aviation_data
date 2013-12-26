SEEDS_PATH = File.expand_path("../seeds", __FILE__)

def seed(clazz, filename)
  sql_path = File.join(SEEDS_PATH, "#{filename}.sql")
  csv_path = File.join(SEEDS_PATH, "#{filename}.csv")
  text_path = File.join(SEEDS_PATH, "#{filename}.txt")

  if clazz.respond_to?(:enumeration_model_updates_permitted=)
    clazz.enumeration_model_updates_permitted = true
  end

  if File.exists?(sql_path)
    puts "Importing #{filename} as SQL"

    data = File.read(sql_path)
    ActiveRecord::Base.connection.execute data
  elsif File.exists?(csv_path)
    puts "Importing #{filename} as CSV"

    CSV.foreach(csv_path) do |row|
      m = clazz.new(:name => row[0].strip, :description => row[1].strip)
      m.save(:validate => false)
    end
  else
    puts "Importing #{filename} as Text"

    File.foreach(text_path).each_with_index do |line, index|
      m = clazz.new(:name => line.chomp)
      m.id = index
      m.save(:validate => false)
    end
  end
end

seed(State, "states")
seed(Country, "countries")
seed(IdentifierType, "identifier_types")
seed(ManufacturerName, "manufacturer_names")
seed(ModelName, "model_names")
seed(Weight, "weights")
seed(BuilderCertification, "builder_certifications")
seed(EngineType, "engine_types")
seed(AircraftType, "aircraft_types")
seed(AircraftCategory, "aircraft_categories")

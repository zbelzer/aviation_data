SEEDS_PATH = File.expand_path("../seeds", __FILE__)

def seed(clazz, filename)
  sql_path = File.join(SEEDS_PATH, "#{filename}.sql")
  csv_path = File.join(SEEDS_PATH, "#{filename}.csv")
  text_path = File.join(SEEDS_PATH, "#{filename}.txt")

  clazz.enumeration_model_updates_permitted = true

  if File.exists?(sql_path)
    puts "Importing #{filename} as SQL"

    data = File.read(sql_path)
    ActiveRecord::Base.connection.execute data
  elsif File.exists?(csv_path)
    puts "Importing #{filename} as CSV"

    CSV.foreach(csv_path) do |row|
      m = clazz.new(:name => row[0], :description => row[1])
      m.save(:validate => false)
    end
  else
    puts "Importing #{filename} as Text"

    File.foreach(text_path).each do |line|
      m = clazz.new(:name => line)
      m.save(:validate => false)
    end
  end
end

seed(State, "states")
seed(IdentifierType, "identifier_types")
seed(ManufacturerName, "manufacturers")
seed(ModelName, "models")
seed(Weight, "weights")

AircraftEngineType.enumeration_model_updates_permitted = true
AircraftEngineType::CODE_MAP.each do |code, name|
  m = AircraftEngineType.new(:name => name)
  m.save(:validate => false)
end

AircraftType.enumeration_model_updates_permitted = true
AircraftType::CODE_MAP.each do |code, name|
  m = AircraftType.new(:name => name)
  m.save(:validate => false)
end

AircraftCategory.enumeration_model_updates_permitted = true
AircraftCategory::CODE_MAP.each do |code, name|
  m = AircraftCategory.new(:name => name.to_s)
  m.save(:validate => false)
end

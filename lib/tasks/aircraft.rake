require 'aviation_data'

namespace :aircraft do
  desc "Imports the aircraft data"
  task :import => :environment do
    AIRCRAFT_TABLE_MAP.each do |type, collection|
      path = File.join(AIRMEN_DIR, type)
      fields = AviationData::HEADERS[type]

      new_path = AviationData::ConversionUtilities.convert_to_json(path, fields)
      AviationData::ImportUtilities.import_into_mongo(DATABASE, collection, new_path, fields)
    end
  end
end

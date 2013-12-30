namespace :airmen do
  desc "Imports the releasable airmen and certificate databases"
  task :import => :environment do
    AviationData::AIRMEN_TABLE_MAP.each do |type, collection|
      path = File.join(AviationData::AIRMEN_DIR, type)
      fields = AviationData::HEADERS[type]

      new_path = AviationData::ConversionUtilities.convert_to_json(path, fields)
      AviationData::ImportUtilities.import_into_mongo(AviationData::DATABASE, collection, new_path, fields)
    end
  end
end

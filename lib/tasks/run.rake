task :run => :environment do
  require 'aviation_data'

  database = "aviation_data_development"
  [
    ['MASTER', 'aircrafts'],
    ['ACFTREF', 'aircraft_references'],
    ['DEREG', 'deregistered'],
    ['DEALER', 'dealers'],
    ['ENGINE', 'engines'],
    ['RESERVED', 'reservations']
  ].each do |type, collection|
    path = File.expand_path("db/data/aircraft/AR012009/#{type}", Rails.root)
    fields = AviationData::HEADERS[type]

    new_path = AviationData::ConversionUtilities.convert_to_json(path, fields)
    AviationData::ImportUtilities.import_into_mongo(database, collection, new_path, fields)
  end
end

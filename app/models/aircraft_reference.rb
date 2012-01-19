class AircraftReference
  include MongoMapper::Document

  key :aircraft_model_code, String, :index => true
  key :manufacturer, String
  key :model_name, String
  key :type_aircraft, String
  key :type_engine, String
  key :aircraft_category_code, String
  key :builder_certification_code, String
  key :engines, Integer
  key :seats, Integer
  key :weight, Integer
  key :cruising_speed, Integer
end

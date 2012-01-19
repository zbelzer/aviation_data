class Master
  include MongoMapper::Document
  set_collection_name "master"

  key :identifier,                String, :index => true
  key :manufacturer,              String
  key :model_name,                String, :index => true
  key :type_aircraft,             Integer
  key :type_engine,               Integer
  key :aircraft_category_code,    Integer
  key :engines,                   Integer
  key :weight,                    String
  key :serial_number,             String, :index => true
  key :year_manufactured,         Integer
  key :certificate_issue_date,    Time
  key :approved_operation_codes,  String
  key :status_code,               String
  key :airworthiness_date,        Time
end

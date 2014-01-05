module FaaData
  DATA_DIR     = Rails.root.join('db/data')
  AIRMEN_DIR   = File.join(DATA_DIR, 'airmen')
  AIRPORT_PATH = File.join(DATA_DIR, 'airports')

  RATINGS = %w(rating1 rating2 rating3 rating4 rating5 rating6 rating7 rating8 rating9 rating10 rating11)
  HEADERS = {
    # 'RELDOMCB' => %w(unique_number first_name last_name address_1 address_2 city state zip country region medical_class medical_date medical_expiration_date),
    # 'RELDOMCC' => %w(unique_number first_name last_name certificate_type level expiration_date) + RATINGS
  }

  AIRCRAFT_TABLES = [
    FaaData::Master,
    FaaData::Acftref,
    # FaaData::Dereg,
    # FaaData::Dealer,
    # FaaData::Engine,
    # FaaData::Reserved
  ]

  AIRMEN_TABLE_MAP = [
    ['RELDOMCB', 'airmen'],
    ['RELDOMCC', 'certificates']
  ]

  def self.import_package(package)
    FaaData::AIRCRAFT_TABLES.each do |data_file|
      puts
      puts "Importing #{data_file}"

      data_file.import_from(package)
    end
  end
end

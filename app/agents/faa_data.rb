module FaaData
  DATA_DIR     = Rails.root.join('db/data')
  AIRMEN_DIR   = File.join(DATA_DIR, 'airmen')
  AIRPORT_PATH = File.join(DATA_DIR, 'airports')

  RATINGS = %w(rating1 rating2 rating3 rating4 rating5 rating6 rating7 rating8 rating9 rating10 rating11)
  HEADERS = {
    # 'RELDOMCB' => %w(unique_number first_name last_name address_1 address_2 city state zip country region medical_class medical_date medical_expiration_date),
    # 'RELDOMCC' => %w(unique_number first_name last_name certificate_type level expiration_date) + RATINGS
  }
  AIRMEN_TABLE_MAP = [
    ['RELDOMCB', 'airmen'],
    ['RELDOMCC', 'certificates']
  ]
end

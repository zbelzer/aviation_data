# Entry point for importing airment information from the FAA.
module FaaData::Airmen
  # Airmen file headers.
  HEADERS = {
    # 'RELDOMCB' => %w(unique_number first_name last_name address_1 address_2 city state zip country region medical_class medical_date medical_expiration_date),
    # 'RELDOMCC' => %w(unique_number first_name last_name certificate_type level expiration_date rating1 rating2 rating3 rating4 rating5 rating6 rating7 rating8 rating9 rating10 rating11)
  }

  # Files found in releasable aircraft data packages.
  AIRMEN_TABLE_MAP = [
    ['RELDOMCB', 'airmen'],
    ['RELDOMCC', 'certificates']
  ]

  # The root path for airman data.
  #
  # @return [Pathname]
  def self.root
    @root ||= FaaData.join('airmen')
  end
end
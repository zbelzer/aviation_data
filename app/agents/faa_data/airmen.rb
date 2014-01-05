# Entry point for importing airmen information from the FAA.
module FaaData::Airmen
  # Files found in releasable aircraft data packages.
  AIRMEN_TABLE_MAP = [
    ['RELDOMCB', 'airmen'],
    ['RELDOMCC', 'certificates']
  ]

  # Import Airman information
  def self.import
    FaaData::Airmen::AIRMEN_TABLE_MAP.each do |type, collection|
      path = FaaData::Airmen.root.join(type)
      fields = AviationData::HEADERS[type]

      new_path = AviationData::ConversionUtilities.convert_to_json(path, fields)
      AviationData::ImportUtilities.import_into_mongo(AviationData::DATABASE, collection, new_path, fields)
    end
  end

  # The root path for airman data.
  #
  # @return [Pathname]
  def self.root
    @root ||= FaaData.join('airmen')
  end
end

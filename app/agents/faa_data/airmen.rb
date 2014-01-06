# Entry point for importing airmen information from the FAA.
module FaaData::Airmen
  # Files found in releasable aircraft data packages.
  AIRMEN_TABLE_MAP = [
    ['RELDOMCB', 'airmen'],
    ['RELDOMCC', 'certificates']
  ]

  # Import Airman information
  def self.import
    FaaData::Airmen::AIRMEN_TABLE_MAP.each do |type, table_name|
      path = FaaData::Airmen.root.join(type)
      fields = AviationData::HEADERS[type]

      FaaData::ConversionUtilities.prepare_for_import(path, columns) do |converted_path|
        ::PostgresImportUtilities.import(table_name, converted_path, columns)
      end
    end
  end

  # The root path for airman data.
  #
  # @return [Pathname]
  def self.root
    @root ||= FaaData.root.join('airmen')
  end
end

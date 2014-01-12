# FAA Airman information file or 'PILOT_BASIC'
module FaaData::Airmen::PilotBasic
  extend FaaData::ReleasableDataFile

  model ::PilotBasic

  # The file name for this data file within a package.
  #
  # @return [String]
  def self.file_name(version)
    if version == FaaData::AirmenPackage::VERSION::V1
      'RELDOMCB'
    else
      super
    end
  end

  # FAA Airmen file headers.
  #
  # @param [String] version
  # @return [Array<String>]
  def self.headers(version)
    base_headers = %w(unique_number first_name last_name address_1 address_2 city state zip country region medical_class medical_date medical_expiration_date)

    if version == FaaData::AirmenPackage::VERSION::V1
      base_headers + ["dummy"]
    else
      base_headers
    end
  end

  # Options to send the import process. Usually hints about how to specially
  # treat this version.
  #
  # V2 has something funky going on where it can't decide if it's a fixed width
  # or a csv format. Some rows are missing a column.
  #
  # @return [Hash]
  def self.import_options(version)
    if version == FaaData::AirmenPackage::VERSION::V1
      {:date_format => "MMYYYY"}
    else
      {:strip_commas => true, :date_format => "MMYYYY"}
    end
  end
end

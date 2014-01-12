# FAA Airman certificate file or 'PILOT_BASIC'
module FaaData::Airmen::PilotCert
  extend FaaData::ReleasableDataFile

  # Headers excluding ratings.
  BASE_HEADERS = %w(unique_number first_name last_name certificate_type level expiration_date)

  # Base rating headers.
  RATINGS_HEADERS     = (1..11).map {|i| "rating#{i}"}

  # Extended rating headers.
  TYPE_RATING_HEADERS = (1..99).map {|i| "typerating#{i}"}

  model ::PilotCert

  # The file name for this data file within a package.
  #
  # @return [String]
  def self.file_name(version)
    if version == FaaData::AirmenPackage::VERSION::V1
      'RELDOMCC'
    else
      super
    end
  end

  # FAA Airmen Certificate file headers.
  #
  # @param [String] version
  # @return [Array<String>]
  def self.headers(version)
    base_headers = BASE_HEADERS + RATINGS_HEADERS
    dummy_header = ["dummy"]

    if version == FaaData::AirmenPackage::VERSION::V1
      base_headers + dummy_header
    else
      base_headers + TYPE_RATING_HEADERS + dummy_header
    end
  end

  # Options to send the import process. Usually hints about how to specially
  # treat this version.
  #
  # @return [Hash]
  def self.import_options(version)
    {:date_format => "MMDDYYYY"}
  end
end

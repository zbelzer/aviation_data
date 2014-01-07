# FAA Airman certificate file or 'PILOT_BASIC'
module FaaData::Airmen::PilotCert
  extend FaaData::ReleasableDataFile

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
    ratings = (1..11).map {|i| "rating#{i}"}
    base_headers = %w(unique_number first_name last_name certificate_type level expiration_date) + ratings

    if version == FaaData::AirmenPackage::VERSION::V1
      base_headers + ["dummy"]
    else
      typeratings = (1..99).map {|i| "typerating#{i}"}
      base_headers + typeratings + ["dummy"]
    end
  end
end

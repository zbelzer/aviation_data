module FaaData::Aircrafts
  # Meta information about the MASTER data file from the FAA's releasable database.
  module Master
    extend FaaData::ReleasableDataFile

    model ::Master

    # Headers that appear in the original specification.
    BASE_HEADERS = %w(
      identifier serial_number aircraft_model_code engine_mode_code year_manufactured type_registrant
      registrant_name street1 street2 registrant_city registrant_state registrant_zip registrant_region county_mail country_mail
      last_activity_date certificate_issue_date
      approved_operation_codes
      type_aircraft type_engine
      status_code transponder_code
      fractional_ownership
      airworthiness_date
      owner_one owner_two owner_three owner_four owner_five
    )

    # Headers that appear in later additions to the specification.
    VERSION_HEADERS = {
      FaaData::AircraftPackage::VERSION::V1 => [],
      FaaData::AircraftPackage::VERSION::V2 => %w(expiration_date unique_id),
      FaaData::AircraftPackage::VERSION::V3 => %w(expiration_date unique_id kit_manufacturer kit_model mode_s_code_hex)
    }

    # Find the headers for this file specified by version.
    #
    # @param [String] version
    # @return [Array<String>]
    def self.headers(version)
      BASE_HEADERS + VERSION_HEADERS[version] 
    end

    # Options to send the import process. Usually hints about how to specially
    # treat this version.
    #
    # @return [Hash]
    def self.import_options(version)
      {:extra_commas => true, :date_format => "YYYYMMDD"}
    end
  end
end

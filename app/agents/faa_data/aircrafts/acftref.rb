module FaaData::Aircrafts
  # Meta information about the ACTREF data file from the FAA's releasable database.
  module Acftref
    extend FaaData::ReleasableDataFile

    model ::AircraftReference

    # Find the headers for this file specified by version.
    #
    # @param [String] version
    # @return [Array<String>]
    def self.headers(version)
      %w(code manufacturer_name model_name aircraft_type_id engine_type_id aircraft_category_id builder_certification_id engines seats weight cruising_speed)
    end

    # Options to send the import process. Usually hints about how to specially
    # treat this version.
    #
    # @return [Hash]
    def self.import_options(version)
      {:extra_commas => true}
    end
  end
end

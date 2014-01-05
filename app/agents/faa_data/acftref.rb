# Meta information about the ACTREF data file from the FAA's releasable database.
module FaaData::Acftref
  extend FaaData::ReleasableDataFile

  model ::AircraftReference

  # Find the headers for this file specified by version.
  #
  # @param [String] version
  # @return [Array<String>]
  def self.headers(version)
    %w(code manufacturer_name model_name aircraft_type_id engine_type_id aircraft_category_id builder_certification_id engines seats weight cruising_speed)
  end
end

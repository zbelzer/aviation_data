module FaaData::Aircrafts
  # Meta information about the ENGINE data file from the FAA's releasable database.
  module Engine
    extend FaaData::ReleasableDataFile

    model ::Engine

    # Find the headers for this file specified by version.
    #
    # @param [String] version
    # @return [Array<String>]
    def self.headers(version)
      %w(code manufacturer model type horsepower thrust)
    end
  end
end

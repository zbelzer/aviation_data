module FaaData::Aircrafts
  # Meta information about the RESERVED data file from the FAA's releasable database.
  module Reserved
    extend FaaData::ReleasableDataFile

    model ::Reserved

    # Headers that appear in the original specification.
    def self.headers(version)
      %w(identifier registrant address_1 address_2 city state zip code reserved_date tr expirtation_date identifier_change)
    end
  end
end

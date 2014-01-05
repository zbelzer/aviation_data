# Meta information about the RESERVED data file from the FAA's releasable database.
module FaaData::Reserved
  extend FaaData::ReleasableDataFile

  def self.model
    ::Reserved
  end

  # Headers that appear in the original specification.
  def self.headers(version)
    %w(identifier registrant address_1 address_2 city state zip code reserved_date tr expirtation_date identifier_change)
  end
end

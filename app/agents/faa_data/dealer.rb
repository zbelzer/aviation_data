# Meta information about the DEALER data file from the FAA's releasable database.
module FaaData::Dealer
  extend FaaData::ReleasableDataFile

  def self.model
    ::Dealer
  end

  # Find the headers for this file specified by version.
  #
  # @param [String] version
  # @return [Array<String>]
  def self.headers(version)
    %w(certificate_number ownership certificate_date expiration_date expiration_flag certificate_issue_count name address_1 address_2 city state_abbrev zip_code other_names_count other_names_1 other_names_2 other_names_3 other_names_4 other_names_5 other_names_6 other_names_7 other_names_8 other_names_9 other_names_10 other_names_11 other_names_12 other_names_13 other_names_14 other_names_15 other_names_16 other_names_17 other_names_18 other_names_19 other_names_20 other_names_21 other_names_22 other_names_23 other_names_24 other_names_25)
  end
end

# Meta information about the DEREG data file from the FAA's releasable database.
module FaaData::Dereg
  extend FaaData::ReleasableDataFile

  def self.model
    ::Dereg
  end

  # Find the headers for this file specified by version.
  #
  # @param [String] version
  # @return [Array<String>]
  def self.headers(version)
    %w(identifier serial_number aircraft_model_code status_code name address_1 address_2 city_mail state_abbrev_mail zip_code_mail engine_mode_code year_manufactured certification region county_mail country_mail airworthiness_date cancel_date mode_s_code indicator_group exp_country last_act_date cert_issue_date street_physical street2_physical city_physical state_abbrev_physical zip_code_physical county_physical country_physical owner_1 owner_2 owner_3 owner_4 owner_5)
  end
end

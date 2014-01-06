# FAA Airman information file or 'PILOT_BASIC'
module FaaData::Airmen::PilotBasic
  extend FaaData::ReleasableDataFile

  model ::PilotBasic

  # FAA Airmen file headers.
  #
  # @return [Array<String>]
  def self.headers(package)
    %w(unique_number first_name last_name address_1 address_2 city state zip country region medical_class medical_date medical_expiration_date)
  end
end

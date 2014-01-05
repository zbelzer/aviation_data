# FAA Airman information file or 'RELDOMCB'
module FaaData::Airmen::Airmen
  # FAA Airmen file headers.
  #
  # @return [Array<String>]
  def self.headers
    %w(unique_number first_name last_name address_1 address_2 city state zip country region medical_class medical_date medical_expiration_date)
  end
end

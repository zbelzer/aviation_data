# FAA Airman certificate file or 'RELDOMCC'
module FaaData::Airmen::Certificates
  # FAA Airmen Certificate file headers.
  #
  # @return [Array<String>]
  def self.headers
    %w(unique_number first_name last_name certificate_type level expiration_date rating1 rating2 rating3 rating4 rating5 rating6 rating7 rating8 rating9 rating10 rating11)
  end
end

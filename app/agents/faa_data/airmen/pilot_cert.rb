# FAA Airman certificate file or 'PILOT_BASIC'
module FaaData::Airmen::PilotCert
  extend FaaData::ReleasableDataFile

  model ::PilotCert

  # FAA Airmen Certificate file headers.
  #
  # @return [Array<String>]
  def self.headers(package)
    ratings = (1..11).map {|i| "rating#{i}"}
    typeratings = (1..99).map {|i| "typerating#{i}"}
    %w(unique_number first_name last_name certificate_type level expiration_date) + ratings + typeratings + ["dummy"]
  end
end

class PilotCert < ActiveRecord::Base
  self.table_name = 'pilot_cert'

  scope :missing_certifications, lambda {
    select("airmen.id AS airman_id, certificate_types.id as certificate_type_id, pilot_cert.*").
    joins("JOIN airmen ON airmen.unique_number = pilot_cert.unique_number").
    joins("JOIN certificate_types ON pilot_cert.certificate_type = certificate_types.name").
    joins("LEFT JOIN certificates ON certificates.airman_id = airmen.id AND certificates.certificate_type_id = certificate_types.id").
    where(:certificates => {:id => nil}).
    order(:id)
  }
end

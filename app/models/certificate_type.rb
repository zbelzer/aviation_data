# Classifications of certificates.
class CertificateType < ActiveRecord::Base
  acts_as_enumerated
end

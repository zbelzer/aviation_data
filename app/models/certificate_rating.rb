# Ratings for a certificate.
class CertificateRating < ActiveRecord::Base
  acts_as_enumerated

  has_many :certificates
end

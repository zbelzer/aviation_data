# Information regarding pilot certifications.
class Certificate < ActiveRecord::Base
  belongs_to :airman
  has_enumerated :certificate_type
end

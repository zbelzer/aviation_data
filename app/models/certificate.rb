# Information regarding pilot certifications.
class Certificate < ActiveRecord::Base
  belongs_to :airman
  has_enumerated :certificate_type
  has_enumerated :certificate_level
end

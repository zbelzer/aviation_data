# Information regarding a pilot.
class Airman < ActiveRecord::Base
  has_many :certificates
end

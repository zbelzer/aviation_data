# Information regarding a pilot.
class Airman < ActiveRecord::Base
  has_many :certificates

  # Find the date corresponding to the last imported package.
  # @return [DateTime]
  def self.last_import_date
    maximum(:import_date)
  end
end

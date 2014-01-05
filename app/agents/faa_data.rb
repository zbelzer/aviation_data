# Root module for classes and models dealing with importing data from the FAA.
module FaaData
  # The root path for FAA data.
  #
  # @return [Pathname]
  def self.root
    @root ||= Rails.root.join('db/data')
  end

end

# Entry point for importing airport information from various sources.
module FaaData::Airports
  # The root path for airport data.
  #
  # @return [Pathname]
  def self.root
    @root ||= FaaData.root.join('airports')
  end
end

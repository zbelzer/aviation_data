# Engine types imported from the FAA.
class EngineType < ActiveRecord::Base
  acts_as_enumerated

  # Render this just as the name for the JSON representation.
  #
  # @return [String]
  def as_json(options = {})
    name
  end
end

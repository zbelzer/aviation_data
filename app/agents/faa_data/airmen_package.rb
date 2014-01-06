# Represents a 'Releasable Aircraft Database Download' package.
class FaaData::AirmenPackage < FaaData::Package
  # @return [Pathname]
  def self.root
    FaaData::Airmen.root
  end

  # @return [String]
  def self.prefix
    "CS"
  end
end

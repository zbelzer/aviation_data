# Represents a 'Releasable Aircraft Database Download' package.
class FaaData::AirmenPackage < FaaData::Package
  # Version identifiers for different variations of headers.
  module VERSION
    # :nodoc:
    V1 = 'V1'
    # :nodoc:
    V2 = 'V2'
  end

  # The inferred version of the package.
  #
  # @return [String]
  def version
    if import_date <= Date.new(2013, 1)
      VERSION::V1
    else
      VERSION::V2
    end
  end

  # @return [Pathname]
  def self.root
    FaaData::Airmen.root
  end

  # @return [String]
  def self.prefix
    "CS"
  end
end

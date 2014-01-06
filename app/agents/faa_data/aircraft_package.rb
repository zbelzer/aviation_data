# Represents a 'Releasable Aircraft Database Download' package.
class FaaData::AircraftPackage < FaaData::Package
  # Version identifiers for different variations of headers.
  module VERSION
    # :nodoc:
    V1 = 'V1'
    # :nodoc:
    V2 = 'V2'
    # :nodoc:
    V3 = 'V3'
  end

  # The inferred version of the package.
  #
  # @return [String]
  def version
    if import_date <= Date.new(2011, 6)
      VERSION::V1
    elsif import_date < Date.new(2012, 11)
      VERSION::V2
    else
      VERSION::V3
    end
  end

  # @return [Pathname]
  def self.root
    FaaData::Aircrafts.root
  end

  # @return [String]
  def self.prefix
    "AR"
  end
end

# Entry point for importing releasable aircraft data from the FAA.
module FaaData::Aircrafts
  # Files found in releasable aircraft data packages.
  FILES = [
    FaaData::Aircrafts::Master,
    FaaData::Aircrafts::Acftref,
    # FaaData::Aircrafts::Dereg,
    # FaaData::Aircrafts::Dealer,
    # FaaData::Aircrafts::Engine,
    # FaaData::Aircrafts::Reserved
  ]

  # Import an FAA data package.
  #
  # @param [FaaData::Package] package
  def self.import_package(package)
    FILES.each do |data_file|
      data_file.import_from(package)
    end
  end

  # The root path for aircraft packages.
  #
  # @return [Pathname]
  def self.root
    FaaData.root.join("aircraft")
  end
end

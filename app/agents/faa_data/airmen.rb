# Entry point for importing airmen information from the FAA.
module FaaData::Airmen
  # Files found in releasable airmen data packages.
  FILES = [
    FaaData::Airmen::PilotBasic,
    FaaData::Airmen::PilotCert
  ]

  # Import Airman information
  def self.import_package(package)
    FILES.each do |data_file|
      data_file.import_from(package)
    end
  end

  # The root path for airman data.
  #
  # @return [Pathname]
  def self.root
    @root ||= FaaData.root.join('airmen')
  end
end

# Base for all data files provided as part of the FAA's releasable aircraft
# database.
module FaaData::ReleasableDataFile
  # Macro to set or get the model this data file will map to.
  #
  # @return [ActiveRecord::Base]
  def model(model = nil)
    model ? @model = model : @model
  end

  # Import the data for this data file from a given package.
  #
  # @param [FaaData::Package] package
  def import_from(package)
    version   = package.version

    file_name = file_name(version)
    options   = import_options(version)
    columns   = headers(version)

    puts
    puts "Importing #{file_name}"

    path    = package.find_file(file_name)

    @model.delete_all

    FaaData::ConversionUtilities.prepare_for_import(path, options) do |converted_path|
      ::PostgresImportUtilities.import(table_name, converted_path, columns)
    end
  end

  # The file name for this data file within a package.
  #
  # @return [String]
  def file_name(version = nil)
    name.split('::').last.underscore.upcase
  end
  alias_method :to_s, :file_name
  private :file_name

  # Options to send the import process. Usually hints about how to specially
  # treat this version.
  #
  # @return [Hash]
  def import_options(version = nil)
    {}
  end

  # The table name of the model this data file represents.
  #
  # @return [String]
  def table_name
    @model.table_name
  end
  private :table_name

  # Find the headers for this file specified by version.
  #
  # @param [String] version
  # @return [Array<String>]
  def headers(version)
    raise NotImplemented
  end
  private :headers
end

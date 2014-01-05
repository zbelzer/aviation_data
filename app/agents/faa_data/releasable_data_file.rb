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
    path    = package.find_file(file_name)
    columns = headers(package.version)

    @model.delete_all

    FaaData::ConversionUtilities.prepare_for_import(path, columns) do |converted_path|
      ::PostgresImportUtilities.import(table_name, converted_path, columns)
    end
  end

  # The file name for this data file within a package.
  #
  # @return [String]
  def file_name
    name.split('::').last.upcase
  end
  alias_method :to_s, :file_name
  private :file_name

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

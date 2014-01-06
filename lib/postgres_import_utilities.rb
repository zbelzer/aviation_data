# Helper module to wrap the PostgreSQL COPY method.
module PostgresImportUtilities
  # Run the PostgreSQL COPY method.
  #
  # @param [String] table_name Name of the target table.
  # @param [String] path Path to the target data file.
  # @param [Array<String>] columns List of the target table's columns
  def self.import(table_name, path, columns)
    ActiveRecord::Base.connection.execute <<-SQL
      COPY #{table_name} (#{columns.join(', ')}) FROM '#{path}' WITH DELIMITER AS ',';
    SQL
  end
end

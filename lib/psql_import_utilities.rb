module PsqlImportUtilities
  def self.import(collection, path, fields)
    ActiveRecord::Base.connection.execute <<-SQL
      COPY #{collection} (#{fields.join(', ')}) FROM '#{path}' WITH DELIMITER AS ',' NULL '';
    SQL
  end
end

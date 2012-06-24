require 'active_record'

module AviationData
  module ImportUtilities
    def self.import(database, collection, path, fields)
      ActiveRecord::Base.connection.execute <<-SQL
        COPY #{collection} (#{fields.join(', ')}) FROM '#{path}' WITH DELIMITER AS ',' NULL '';
      SQL
    end
  end
end

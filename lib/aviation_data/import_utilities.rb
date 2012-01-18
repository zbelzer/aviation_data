module AviationData
  module ImportUtilities
    extend OutputUtilities

    def self.import_into_mongo(database, collection, path, fields)
      run_step "Importing data into MongoDB" do
        command = "mongoimport -d #{database} -c #{collection} --file #{path} -f #{fields.join(',')} --ignoreBlanks --drop --stopOnError"
        puts command
        system command
      end

      convert_dates(database, collection, fields)

      puts
    end

    def self.convert_dates(database, collection, fields)
      date_fields = fields.select {|field| field =~ /date$/}
      date_column_query = date_fields.map {|field| "{#{field} : {\\$exists : true}}" }.join(', ')
      date_column_conversion = date_fields.map {|field| "#{field} : new Date(doc.#{field})"}.join(', ')

      column_conversions = <<-EOF
        var cursor = db.#{collection}.find({\\$or : [#{date_column_query}]});
        while (cursor.hasNext()) {
          var doc = cursor.next();
          db.#{collection}.update({_id : doc._id}, {\\$set : {#{date_column_conversion}}});
        }
      EOF

      run_step "Converting date columns" do
        `mongo #{database} --eval "#{column_conversions}"`
      end
    end
  end
end

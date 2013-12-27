module BatchImport
  module Aircrafts
    def self.import_latest(file)
      file =~ /AR(\d{2})(\d{4})/
      import_date = Date.new($2.to_i, $1.to_i)

      BatchRunner.run(Master.missing_aircraft) do |batch_scope|

        aircrafts = batch_scope.each_with_object([]) do |record, memo|
          begin
            ident = Identifier.find_by_code(record.identifier)
            model = Model.find_by_code(record.aircraft_model_code)

            memo << Aircraft.new(
              :identifier_id     => ident.id,
              :model_id          => model.id,
              :year_manufactured => record.year_manufactured,
              :transponder_code  => record.transponder_code,
              :as_of             => import_date
            )
          rescue => e
            puts "Could not create aircraft for"
            puts record.attributes
            puts e.message
            # puts e.backtrace.join("\n")
          end
        end

        begin
          Aircraft.import(aircrafts)
        rescue => e
          print e.message + "\n"
          print "RESCUING\n" + aircrafts.map(&:attributes).join("\n")
        end
      end
    end
  end
end

module BatchImport::Aircrafts
  def self.import_latest(package)
    BatchImport::Runner.run(Master.missing_aircraft) do |batch_scope|

      aircrafts = batch_scope.each_with_object([]) do |record, memo|
        if record.identifier_id.blank? ||  record.model_id.blank?
          puts "Could not create aircraft for"
          puts record.attributes
        else
          memo << Aircraft.new(
            :identifier_id     => record.identifier_id,
            :model_id          => record.model_id,
            :year_manufactured => record.year_manufactured,
            :transponder_code  => record.transponder_code,
            :as_of             => package.import_date
          )
        end
      end

      begin
        Aircraft.import(aircrafts, :validate => false)
      rescue => e
        print e.message + "\n"
        print "RESCUING\n" + aircrafts.map(&:attributes).join("\n")
      end
    end
  end
end

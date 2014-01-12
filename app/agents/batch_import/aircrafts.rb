# Utilities for importing data from Master to Aircrafts.
module BatchImport::Aircrafts
  # Create only new Aircrafts from current Master information.
  #
  # @param [Package] package
  def self.import_latest(package)
    BatchImport::Runner.run(Master.missing_aircraft) do |batch_scope|

      aircrafts = batch_scope.each_with_object([]) do |record, memo|
        memo << Aircraft.new(
          :identifier_id     => record.identifier_id,
          :model_id          => record.model_id,
          :year_manufactured => record.year_manufactured,
          :transponder_code  => record.transponder_code,
          :as_of             => package.import_date
        )
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

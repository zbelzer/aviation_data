# Utilities for importing data from PilotBasic to Airman.
module BatchImport::Airmen
  extend BatchImport::Helpers

  # Create only new Airmen from current PilotBasic information.
  #
  # @param [Package] package
  def self.import_latest(package)
    BatchImport::Runner.run(PilotBasic.missing_airmen) do |batch_scope|

      airmen = batch_scope.each_with_object([]) do |record, memo|
        airman = Airman.new(
          :unique_number => record.unique_number,
          :first_name    => record.first_name,
          :last_name     => record.last_name,
          :medical_class => record.medical_class,
          :import_date   => package.import_date
        )

        set_date(record, airman, :medical_date)
        set_date(record, airman, :medical_expiration_date)

        memo << airman
      end

      Airman.import(airmen, :validate => false)
    end
  end

end

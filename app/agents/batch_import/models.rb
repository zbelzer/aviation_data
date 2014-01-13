# Utilities for importing data from AircraftReference to Model.
module BatchImport::Models
  extend BatchImport::Helpers

  # Create only new Models from current Master information.
  #
  # @param [Package] package
  def self.import_latest(package)
    BatchImport::Runner.run(AircraftReference.missing_models) do |batch_scope|

      models = batch_scope.each_with_object([]) do |record, memo|
        model = Model.new(
          :code                     => record.code,

          :aircraft_type_id         => record.aircraft_type_id,
          :aircraft_category_id     => record.aircraft_category_id,
          :builder_certification_id => record.builder_certification_id,
          :engine_type_id           => record.engine_type_id,

          :engines                   => record.engines,
          :seats                     => record.seats,
          :cruising_speed            => record.cruising_speed
        )

        set_enum(record, model, :manufacturer_name, ManufacturerName)
        set_enum(record, model, :model_name, ModelName)
        set_enum(record, model, :weignt, Weight)

        memo << model
      end 

      Model.import(models, :validate => false)
    end
  end
end

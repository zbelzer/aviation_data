# Utilities for importing data from AircraftReference to Model.
module BatchImport::Models
  # Create only new Models from current Master information.
  #
  # @param [Package] package
  def self.import_latest
    ManufacturerName.enumeration_model_updates_permitted = true
    ModelName.enumeration_model_updates_permitted = true

    BatchImport::Runner.run(AircraftReference.missing_models) do |batch_scope|
      models = batch_scope.each_with_object([]) do |record, memo|
        manufacturer_name = ManufacturerName[record.manufacturer_name] || ManufacturerName.create(:name => record.manufacturer_name)
        model_name        = ModelName[record.model_name] || ModelName.create(:name => record.model_name)

        begin
          memo << Model.new(
            :code                     => record.code,

            :aircraft_type_id         => record.aircraft_type_id,
            :aircraft_category_id     => record.aircraft_category_id,
            :builder_certification_id => record.builder_certification_id,
            :engine_type_id           => record.engine_type_id,

            :manufacturer_name_id      => manufacturer_name.id,
            :model_name_id             => model_name.id,
            :weight_id                 => Weight[record.weight].id,

            :engines                   => record.engines,
            :seats                     => record.seats,
            :cruising_speed            => record.cruising_speed
          )
        rescue => e
          puts "Failed to import:"
          puts record.attributes.inspect
          puts e.message
          # puts e.backtrace.join("\n")
        end
      end 

      Model.import(models, :validate => false)
    end

    ManufacturerName.enumeration_model_updates_permitted = false
    ModelName.enumeration_model_updates_permitted = false
  end
end

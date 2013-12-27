module BatchImport
  module Models
    def self.import_latest
      BatchRunner.run(AircraftReference.missing_models) do |batch_scope|

        models = batch_scope.each_with_object([]) do |record, memo|
          begin
            memo << Model.new(
              :code                     => record.code,

              :aircraft_type_id         => record.aircraft_type_id,
              :aircraft_category_id     => record.aircraft_category_id,
              :builder_certification_id => record.builder_certification_id,
              :engine_type_id           => record.engine_type_id,

              :manufacturer_name_id      => ManufacturerName[record.manufacturer_name].id,
              :model_name_id             => ModelName[record.model_name].id,
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

        Model.import(models)
      end
    end
  end
end

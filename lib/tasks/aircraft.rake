require 'aviation_data'
require 'batch_runner'
require 'activerecord-import'
require 'fileutils'

namespace :aircraft do
  desc "Imports the aircraft data"
  task :clear => :environment do
    Master.delete_all
    AircraftReference.delete_all

    Identifier.delete_all
    Model.delete_all

    Aircraft.delete_all
  end

  task :import, [:file] => :environment do |t, args|
    Rake::Task['aircraft:source'].invoke(args[:file])
    Rake::Task['aircraft:identifiers'].invoke(args[:file])
    Rake::Task['aircraft:models'].invoke(args[:file])
  end

  task :source, [:file] => :environment do |t, args|
    AviationData::AIRCRAFT_TABLE_MAP.each do |type, collection|
      puts
      puts "Importing #{type.upcase}"

      file = args[:file]

      fields = AviationData::HEADERS[type]
      original_path = Rails.root.join("db/data/aircraft/#{file}/#{type.upcase}")

      prepared_path = AviationData::ConversionUtilities.prepare_for_import(original_path, fields)
      AviationData::ImportUtilities.import(AviationData::DATABASE, collection, prepared_path, fields)
      FileUtils.rm prepared_path
    end
  end

  desc "Imports identifiers from the MASTER file"
  task :identifiers, [:file] => :environment do |t, args|
    puts
    puts "Importing identifiers from MASTER"

    BatchRunner.run(Master) do |limit, offset|
      puts "Thread started with limit #{limit} offset #{offset}"

      identifiers = []

      Master.order(:id).limit(limit).offset(offset).all.each do |record|
        unless Identifier.where(:code => record.identifier).exists?

          identifiers << Identifier.new(
            :identifier_type_id => IdentifierType[:n_number],
            :code               => record.identifier
          )
        end
      end

      Identifier.import identifiers
      puts "Imported #{identifiers.size} new identifiers"
    end
  end

  desc "Imports models from the ACFTREF file"
  task :models, [:file] => :environment do |t, args|
    puts
    puts "Importing models from ACFTREF"

    BatchRunner.run(AircraftReference) do |limit, offset|
      puts "Thread started with limit #{limit} offset #{offset}"

      models = []

      AircraftReference.order(:id).limit(limit).offset(offset).all.each do |record|
        unless Model.where(:code => record.code).exists?

          begin
            models << Model.new(
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
            puts e.backtrace.join("\n")
          end
        end 
      end

      Model.import models
      puts "Imported #{models.size} new models"
    end
  end

  desc "Imports aircrafts from the MASTER file"
  task :aircrafts, [:file] => :environment do |t, args|
    puts
    puts "Importing aircrafts from MASTER"

    file = args[:file]
    file =~ /AR(\d{2})(\d{4})/
    import_date = Date.new($2.to_i, $1.to_i)

    BatchRunner.run(Master) do |limit, offset|
      puts "Thread started with limit #{limit} offset #{offset}"

      aircrafts = []

      Master.order(:id).limit(limit).offset(offset).all.each do |record|
        begin
          ident = Identifier.where(:code => record.identifier).first
          model = Model.where(:code => record.aircraft_model_code).first

          aircrafts << Aircraft.new(
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

      Aircraft.import aircrafts
      puts "Imported #{aircrafts.size} new aircrafts"
    end
  end

end

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

  task :import => :environment do
    Rake::Task['aircraft:clear'].invoke
    Rake::Task['aircraft:source'].invoke
    Rake::Task['aircraft:identifiers'].invoke
    Rake::Task['aircraft:models'].invoke
  end

  task :source => :environment do
    AviationData::AIRCRAFT_TABLE_MAP.each do |type, collection|
      puts
      puts "Importing #{type.upcase}"

      fields = AviationData::HEADERS[type]
      original_path = Rails.root.join("db/data/aircraft/AR012009/#{type.upcase}")

      prepared_path = AviationData::ConversionUtilities.prepare_for_import(original_path, fields)
      AviationData::ImportUtilities.import(AviationData::DATABASE, collection, prepared_path, fields)
      FileUtils.rm prepared_path
    end
  end

  desc "Imports identifiers from the MASTER file"
  task :identifiers => :environment do
    puts
    puts "Importing identifiers from MASTER"

    BatchRunner.run(Master) do |limit, offset|
      puts "Thread started with limit #{limit} offset #{offset}"

      identifiers = []

      Master.order(:id).limit(limit).offset(offset).all.each do |record|
        unless Identifier.where(:code => record.identifier).exists?
          identifiers << Identifier.new(:identifier_type => IdentifierType[:n_number], :code => record.identifier)
        end
      end

      Identifier.import identifiers
      puts "Imported #{identifiers.size} new identifiers"
    end
  end

  desc "Imports models from the ACFTREF file"
  task :models => :environment do
    puts
    puts "Importing models from ACFTREF"

    BatchRunner.run(AircraftReference) do |limit, offset|
      puts "Thread started with limit #{limit} offset #{offset}"

      models = []

      AircraftReference.order(:id).limit(limit).offset(offset).all.each do |record|
        unless Model.where(:code => record.code).exists?
          aircraft_type_name = AircraftType::CODE_MAP[record.aircraft_type]
          aircraft_category_name = AircraftCategory::CODE_MAP[record.aircraft_category_code]
          builder_certification_name = BuilderCertification::CODE_MAP[record.builder_certification_code]
          engine_type_name = EngineType::CODE_MAP[record.engine_type]

          begin
            models << Model.new(
              :code                      => record.code,

              :manufacturer_name_id      => ManufacturerName[record.manufacturer_name].id,
              :model_name_id             => ModelName[record.model_name].id,
              :aircraft_type_id          => AircraftType[aircraft_type_name].id,
              :aircraft_category_id      => AircraftCategory[aircraft_category_name].id,
              :engine_type_id            => EngineType[engine_type_name].id,
              :builder_certification_id  => BuilderCertification[builder_certification_name].id,
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
      end

      Model.import models
      puts "Imported #{models.size} new models"
    end
  end

  desc "Imports aircrafts from the MASTER file"
  task :aircrafts => :environment do
    puts
    puts "Importing aircrafts from MASTER"

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
            :transponder_code  => record.transponder_code
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

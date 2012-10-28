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

  desc "Imports aircrafts from the MASTER file"
  task :aircrafts => :environment do
    puts
    puts "Importing aircrafts from MASTER"

    BatchRunner.run(Master) do |limit, offset|
      puts "Thread started with limit #{limit} offset #{offset}"

      aircrafts = []

      Master.order(:id).limit(limit).offset(offset).all.each do |record|
        ident = nil
        model = nil
        begin
          ident = Identifier.where(:code => record.identifier).first
          model = Model.where(:code => record.aircraft_model_code).first
          aircrafts << Aircraft.new(:identifier_id => ident.id, :model_id => model.id)
        rescue => e
          puts "Could not create aircraft for"
          puts record.attributes
          puts e.message
        end
      end

      Aircraft.import aircrafts
      puts "Imported #{aircrafts.size} new aircrafts"
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

          begin
            models << Model.new(
              :code                       => record.code,
              :manufacturer_name_id       => ManufacturerName[record.manufacturer_name].id,
              :model_name_id              => ModelName[record.model_name].id,
              :aircraft_type_id           => AircraftType[aircraft_type_name].id,
              :aircraft_category_code     => record.aircraft_category_code,
              :builder_certification_code => record.builder_certification_code,
              :engines                    => record.engines,
              :seats                      => record.seats,
              :weight_id                  => Weight[record.weight].id,
              :cruising_speed             => record.cruising_speed
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
end

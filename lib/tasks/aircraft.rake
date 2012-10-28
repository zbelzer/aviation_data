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

      path = File.join(AviationData::AIRCRAFT_DIR, type)
      fields = AviationData::HEADERS[type]

      path = File.expand_path("../../../db/data/aircraft/AR012009/#{type.upcase}", __FILE__)

      new_path = AviationData::ConversionUtilities.prepare_for_import(path, fields)
      AviationData::ImportUtilities.import(AviationData::DATABASE, collection, new_path, fields)
      FileUtils.rm new_path
    end
  end

  task :identifiers => :environment do
    puts "Importing from MASTER"

    BatchRunner.run(Master) do |limit, offset|
      puts "Thread started with limit #{limit} offset #{offset}"

      identifiers = []

      Master.order(:id).limit(limit).offset(offset).all.each do |record|
        if Identifier.where(:code => record.identifier).exists?
          puts "Found existing identifier: #{record.identifier}"
        else
          identifiers << Identifier.new(:identifier_type => IdentifierType[:n_number], :code => record.identifier)
        end
      end

      Identifier.import identifiers
    end
  end

  task :models => :environment do
    puts "Importing from ACFTREF"

    BatchRunner.run(AircraftReference) do |limit, offset|
      puts "Thread started with limit #{limit} offset #{offset}"

      models = []

      AircraftReference.limit(limit).offset(offset).all.each do |record|
        if Model.where(:code => record.code).exists?
          puts "Found existing model: #{record.code}"
        else
          aircraft_type_name = AircraftType::CODE_MAP[record.aircraft_type]

          begin
            models << Model.new(
              :code             => record.code,
              :manufacturer_id  => ManufacturerName[record.manufacturer_name].id,
              :model_name_id    => ModelName[record.model_name].id,
              :aircraft_type_id => AircraftType[aircraft_type_name].id
            )
          rescue => e
            puts "Failed to import: "
            puts record.attributes.inspect
          end
        end 
      end

      Model.import models
    end
  end
end

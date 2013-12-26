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
    AviationData::AIRCRAFT_TABLE_MAP.each do |type, collection, table_name|
      table = table_name.constantize
      table.delete_all

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

    scope = Master.
      joins("LEFT JOIN identifiers ON master.identifier = identifiers.code").
      where(:identifiers => {:code => nil})

    BatchRunner.run(Master, scope) do |limit, offset|
      print "Batch started with limit #{limit} offset #{offset}\n"

      identifiers = []

      scope.order(:id).limit(limit).offset(offset).all.each do |record|
        identifiers << Identifier.new(
          :identifier_type_id => IdentifierType[:n_number],
          :code               => record.identifier
        )
      end

      Identifier.import identifiers
      print "Imported #{identifiers.size} new identifiers\n"
    end
  end

  desc "Imports models from the ACFTREF file"
  task :models, [:file] => :environment do |t, args|
    puts
    puts "Importing models from ACFTREF"

    scope = AircraftReference.
      joins("LEFT JOIN models ON aircraft_reference.code = models.code").
      where(:models => {:code => nil})

    BatchRunner.run(AircraftReference, scope) do |limit, offset|
      print "Batch started with limit #{limit} offset #{offset}\n"

      models = []

      scope.order(:id).limit(limit).offset(offset).all.each do |record|
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
          # puts e.backtrace.join("\n")
        end
      end 

      Model.import models
      print "Imported #{models.size} new models\n"
    end
  end

  desc "Imports aircrafts from the MASTER file"
  task :aircrafts, [:file] => :environment do |t, args|
    puts
    puts "Importing aircrafts from MASTER"

    file = args[:file]
    file =~ /AR(\d{2})(\d{4})/
    import_date = Date.new($2.to_i, $1.to_i)

    unique_sql = Master.
      select("master.id").
      joins("JOIN identifiers ON master.identifier = identifiers.code").
      joins("JOIN models ON master.aircraft_model_code = models.code").
      joins("LEFT JOIN aircrafts ON (aircrafts.identifier_id = identifiers.id AND aircrafts.model_id = models.id)").
      where(:aircrafts => {:id => nil}).to_sql

    scope = Master.where("id IN (#{unique_sql})")

    BatchRunner.run(Master, scope) do |limit, offset|
      print "Batch started with limit #{limit} offset #{offset}\n"

      aircrafts = []

      scope.order(:id).limit(limit).offset(offset).all.each do |record|
        begin
          ident = Identifier.find_by_code(record.identifier)
          model = Model.find_by_code(record.aircraft_model_code)

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

      begin
        Aircraft.import aircrafts
      rescue => e
        print e.message + "\n"
        print "RESCUING\n" + aircrafts.map(&:attributes).join("\n")
      end

      print "Imported #{aircrafts.size} new aircrafts\n"
    end
  end

end

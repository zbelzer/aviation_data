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
    FaaData.import_from_file(args[:file])
  end

  desc "Imports identifiers from the MASTER file"
  task :identifiers, [:file] => :environment do |t, args|
    puts
    puts "Importing identifiers from MASTER"

    BatchImport::Identifiers.import_latest
  end

  desc "Imports models from the ACFTREF file"
  task :models, [:file] => :environment do |t, args|
    puts
    puts "Importing models from ACFTREF"

    BatchImport::Models.import_latest
  end

  desc "Imports aircrafts from the MASTER file"
  task :aircrafts, [:file] => :environment do |t, args|
    puts
    puts "Importing aircrafts from MASTER"

    BatchImport::Aircrafts.import_latest(args[:file])
  end

end

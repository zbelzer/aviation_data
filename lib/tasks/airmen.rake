namespace :airmen do
  desc "Imports the releasable airmen and certificate databases"
  task :import => :environment do
    FaaData::AirmenPackage.find.each do |package|
      FaaData::Airmen.import_package(package)
    end
  end
end

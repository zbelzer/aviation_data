namespace :airmen do
  desc "Imports the releasable airmen and certificate databases"
  task :import => :environment do
    FaaData::Airmen.import
  end
end

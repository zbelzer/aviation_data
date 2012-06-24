namespace :s3 do  
  task :s3_prereqs => :environment do
    require 'aviation_data/s3'
  end
  
  desc 'Download FAA data from s3'
  task :download => :s3_prereqs do
    AviationData::S3.download
  end
  
  desc 'Upload FAA data to s3'
  task :upload => :s3_prereqs do
    AviationData::S3.upload
  end
  
  desc 'List FAA data on s3'
  task :list => :s3_prereqs do
    AviationData::S3.list
  end
end

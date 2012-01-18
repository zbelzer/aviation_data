def print_now(msg)
  print msg
  STDOUT.flush
end

require 'aircraft/package'

namespace :faa do
  namespace :aircraft do

    desc 'Updates the FAA database'
    task :import => :environment do |t, args|
      packages = Faa::Package.find_packages

      packages.each do |package|
        count = 0
        # child = fork do
        file = package.directory
        print_now "Importing from #{file}... "

        time = Benchmark.realtime do
          count = Master.import_aircraft_from_csv(file)
        end

        puts "Imported #{count} aircraft in #{time} seconds"
        # end

      end

      # Process.wait
    end

    desc 'Clears the FAA Aircraft database'
    task :clear => :environment do
      Master.delete_all
    end

  end
end

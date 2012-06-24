require 'aviation_data'

namespace :aircraft do
  desc "Imports the aircraft data"
  task :import => :environment do
    Identifier.delete_all
    # Master.delete_all

    # AviationData::AIRCRAFT_TABLE_MAP.each do |type, collection|
    #   path = File.join(AviationData::AIRCRAFT_DIR, type)
    #   fields = AviationData::HEADERS[type]

    #   path = File.expand_path("../../../db/data/aircraft/AR012009/#{type.upcase}", __FILE__)
    #   # new_path = AviationData::ConversionUtilities.prepare_for_import(path, fields)
    #   new_path = "#{path}.working"
    #   AviationData::ImportUtilities.import(AviationData::DATABASE, collection, new_path, fields)
    # end

    threads = []
    batches = []

    total = Master.count
    running_total = total
    batch_size = total / 8

    limit = 0
    offset = 0

    puts "Total #{total}"
    puts "Batch Size #{batch_size}"

    while running_total > 0
      if running_total < batch_size
        limit = running_total
      else
        limit = batch_size
      end
      running_total -= limit

      batches << [limit, offset]

      offset += batch_size
    end

    Thread.abort_on_exception = true

    Parallel.map(batches, :preserve_results => false) do |limit, offset|
      ActiveRecord::Base.connection.reconnect!

      puts "Identifiers limit #{limit} offset #{offset}"

      Master.limit(limit).offset(offset).all.each do |record|
        # if ident = Identifier.where(:code => record.identifier).first
        #   puts "Found existing identifier: #{record.identifier}"
        # else
          ident = Identifier.new(:identifier_type => IdentifierType[:n_number], :code => record.identifier)
          ident.save(:validate => false)
        # end
      end
    end
  end
end

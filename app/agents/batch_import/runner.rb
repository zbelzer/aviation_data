module BatchImport::Runner
  PROCESS_COUNT = 6.0
  PARALLEL_OPTIONS = {
    :preserve_results => false,
    :in_processes     => PROCESS_COUNT
  }

  def self.run(scope)
    total = scope.count

    batch_size =
     if total < PROCESS_COUNT
       total
     else
       (total / PROCESS_COUNT).ceil
     end

    puts "Importing from table #{scope.name} in batches"
    puts " -- total records: #{total}"
    puts " -- batch size: #{batch_size}"

    batches = create_batches(batch_size, total)

    Parallel.map(batches, PARALLEL_OPTIONS) do |current_limit, current_offset|
      print "Batch started with limit #{current_limit} offset #{current_offset}\n"

      ActiveRecord::Base.connection.reconnect!

      yield scope.limit(current_limit).offset(current_offset)
    end

    begin
      ActiveRecord::Base.connection.reconnect!
    rescue
      ActiveRecord::Base.connection.reconnect!
    end

    puts "Import Complete"
  end

  def self.create_batches(batch_size, total)
    batches = []
    limit   = 0
    offset  = 0
    running_total = total

    while running_total > 0
      limit = running_total < batch_size ? running_total : batch_size
      running_total -= limit

      batches << [limit, offset]

      offset += batch_size
    end

    batches
  end
end

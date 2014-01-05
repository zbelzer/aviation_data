# Parallel batch import utility.
module BatchImport::Runner
  # Number of processes to run.
  PROCESS_COUNT = 6.0

  # Options to send the Parallel helper.
  PARALLEL_OPTIONS = {
    :preserve_results => false,
    :in_processes     => PROCESS_COUNT
  }

  # Run a batch import, splitting the models returned by the given scope into
  # parallelizable batches.
  #
  # @param [ActiveRecord::Relation] scope
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

  # Helper for the simple math to split up a number into chunks.
  #
  # @param [Integer] batch_size
  # @param [Integer] total
  # @return [Array<Array<limit, offset>>]
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

module BatchRunner
  PROCESS_COUNT = 6

  def self.run(scope)
    batches = []
    total = scope.count

    running_total = total
    batch_size = total < PROCESS_COUNT ? total : (total / PROCESS_COUNT)

    limit = 0
    offset = 0

    puts "Importing from table #{scope.name} in batches"
    puts " -- total records: #{total}"
    puts " -- batch size: #{batch_size}"

    while running_total > 0
      limit = running_total < batch_size ? running_total : batch_size
      running_total -= limit

      batches << [limit, offset]

      offset += batch_size
    end

    Thread.abort_on_exception = true

    limit = nil if limit.zero?
    offset = nil if offset.zero?

    options = {
      :preserve_results => false,
      :in_processes     => PROCESS_COUNT
    }

    Parallel.map(batches, options) do |current_limit, current_offset|
      print "Batch started with limit #{current_limit} offset #{current_offset}\n"

      ActiveRecord::Base.connection.reconnect!

      batch_scope = scope.limit(current_limit).offset(current_offset)
      records = yield(batch_scope)
      print "Imported #{records[:num_inserts]} new records\n"
    end
  end
end

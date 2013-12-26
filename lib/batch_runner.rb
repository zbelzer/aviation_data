module BatchRunner
  PROCESS_COUNT = 6

  def self.run(name, scope)
    batches = []

    total = scope.count
    running_total = total
    batch_size = total < PROCESS_COUNT ? total : (total / PROCESS_COUNT)

    limit = 0
    offset = 0

    puts "Importing #{name} in batches"
    puts " -- total records: #{total}"
    puts " -- batch size: #{batch_size}"

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

    limit = nil if limit.zero?
    offset = nil if offset.zero?

    Parallel.map(batches, :preserve_results => false, :in_processes => PROCESS_COUNT) do |limit, offset|
      ActiveRecord::Base.connection.reconnect!
      yield(limit, offset)
    end
  end
end

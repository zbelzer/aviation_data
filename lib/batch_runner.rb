module BatchRunner
  def self.run(clazz)
    batches = []

    total = clazz.count
    running_total = total
    batch_size = total / 8

    limit = 0
    offset = 0

    puts "Importing #{clazz.name} in batches"
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

    Parallel.map(batches, :preserve_results => false, :in_processes => 8) do |limit, offset|
      ActiveRecord::Base.connection.reconnect!
      yield(limit, offset)
    end
  end
end

# Parallel batch import utility.
module BatchImport::Runner
  # Batches is a shell model/table used to house our subselections of new
  # records.
  class Batches < ActiveRecord::Base
    # Creates and populates the batches table from the given scope.
    def self.create_from_scope(scope)
      connection.execute "DROP TABLE IF EXISTS #{self.table_name}"

      select_sql    = scope.select_values.join(',')
      remaining_sql = scope.to_sql =~ /(FROM.*)\Z/ && $1
      connection.execute "SELECT #{select_sql} INTO #{self.table_name} #{remaining_sql}"
    end
  end

  # Number of processes to use.
  PROCESS_COUNT = 6

  # Number of total batches to run.
  BATCH_COUNT = 36.0

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
     if total < BATCH_COUNT || BATCH_COUNT.zero?
       total
     else
       (total / BATCH_COUNT).ceil
     end

    puts "Importing from table #{scope.name} in batches"
    puts " -- total records: #{total}"
    puts " -- batch size: #{batch_size}"

    batches = create_batches(batch_size, total)

    Batches.create_from_scope(scope)

    Parallel.map(batches, PARALLEL_OPTIONS) do |current_limit, current_offset|
      print "Batch started with limit #{current_limit} offset #{current_offset}\n"

      connection.reconnect!

      yield Batches.limit(current_limit).offset(current_offset).order(:id)
    end

    begin
      connection.reconnect!
    rescue
      connection.reconnect!
    end

    puts "Import Complete"
  end

  # Convenience method to access active record
  def self.connection
    ActiveRecord::Base.connection
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

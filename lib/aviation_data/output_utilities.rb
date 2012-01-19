require 'benchmark'

module AviationData
  module OutputUtilities
    def self.run_step(step, &block)
      if block_given?
        print "** #{step}..."
        $stdout.flush
        
        time = Benchmark.realtime do
          yield
        end
        puts " #{time.round(2)} seconds"
      else
        puts "** #{step}"
      end
    end
  end
end

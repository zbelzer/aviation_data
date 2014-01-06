# Utility functions for preparing FAA data for direct import.
module FaaData::ConversionUtilities
  extend self

  # Run all procedures to prepare an FAA data file for import.
  #
  # @param [String] original_path
  # @yield [String] path Working path of prepared data
  def prepare_for_import(original_path)
    # puts "Preparing #{original_path} for import"

    path = "#{original_path}.working"
    FileUtils.cp(original_path, path)

    compress_whitespace(path)
    remove_header(path)
    escape_quotes(path)
    fix_columns(path)
    format_dates(path)

    yield path
  ensure
    # FileUtils.rm path if File.exists?(path)
  end

  # Escape quotes.
  #
  # @param [String] path
  def escape_quotes(path)
    run_step "Escaping quotes" do
      `sed -r -i "s#\\"#\\\"#g" #{path}`
    end
  end

  # Fill empty columns with data.
  #
  # @param [String] path
  def fill_empty_columns(path)
    run_step "Filling empty columns" do
      null = '\\\\\N'
      `sed -r -i "s#,,#,#{null},#g" #{path}`
      `sed -r -i "s#,\\$#,#{null}#g" #{path}`
    end
  end

  # Strip excess whitespace and carriage returns.
  #
  # @param [String] path
  def compress_whitespace(path)
    run_step "Compressing whitespace" do
      `sed -r -i "s/\s+,/,/g" #{path}`
      `sed -r -i "s/\r$//g" #{path}`
    end
  end

  # Correct hanging columns that are sometimes present.
  #
  # @param [String] path
  def fix_columns(path)
    run_step "Fixing columns" do
      `sed -r -i "s/([^,]),$/\\1/g" #{path}`
      # `sed -r -i "s/(,\r|\032)/,/g" #{path}`
      `sed -i 's/,\\\\\,/,,/g' #{path}`
    end
  end

  # Remove the header row in a file.
  #
  # @param [String] path
  def remove_header(path)
    run_step "Dropping provided header" do
      `sed '1d' -i #{path}`
    end
  end

  # Format dates for direct import into a PostgreSQL database.
  #
  # @param [String] path
  def format_dates(path)
    run_step "Formatting dates for native conversion" do
      `sed -r -i "s#,([1-2]{1}[0-9]{3})([0-9]{2})([0-9]{2})#,\\2\/\\3/\\1#g" #{path}`
      `sed -r -i "s#,([0-9]{2})([1-2]{1}[0-9]{3})#,\\2\/01\/\\1#g" #{path}`
    end
  end

  # Run a conversion step with console output and benchmarking info.
  #
  # @param [String] message Message to display on the console
  def run_step(message, &block)
    output_disabled = Rails.env.test?

    if block_given?
      unless output_disabled
        print "** #{message}..."
        $stdout.flush
      end

      time = Benchmark.realtime do
        yield
      end
      puts " #{time.round(2)} seconds" unless output_disabled
    else
      puts "** #{message}" unless output_disabled
    end
  end
end

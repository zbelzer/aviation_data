# Utility functions for preparing FAA data for direct import.
module FaaData::ConversionUtilities
  extend self

  # Run all procedures to prepare an FAA data file for import.
  #
  # @param [String] original_path
  # @yield [String] path Working path of prepared data
  def prepare_for_import(original_path, options = {})
    # puts "Preparing #{original_path} for import"

    path = "#{original_path}.working"

    unless File.exist?(path)
      FileUtils.cp(original_path, path)

      compress_whitespace(path, options)
      remove_header(path, options)
      escape_quotes(path, options)
      fix_columns(path, options)
      format_dates(path, options)
    end

    yield path
  ensure
    FileUtils.rm path if File.exists?(path)
  end

  # Sed command to run.
  #
  # @return [String]
  def sed
    "/usr/bin/env gsed -r"
  end

  # Escape quotes.
  #
  # @param [Hash] options
  # @param [String] path
  def escape_quotes(path, options = {})
    run_step "Escaping quotes" do
      `#{sed} -i "s#\\"#\\\"#g" #{path}`
    end
  end

  # Fill empty columns with data.
  #
  # @param [String] path
  def fill_empty_columns(path)
    run_step "Filling empty columns" do
      null = '\\\\\N'
      `#{sed} -i "s#,,#,#{null},#g" #{path}`
      `#{sed} -i "s#,\\$#,#{null}#g" #{path}`
    end
  end

  # Strip excess whitespace and carriage returns.
  #
  # @param [Hash] options
  # @param [String] path
  def compress_whitespace(path, options = {})
    run_step "Compressing whitespace" do
      `#{sed} -i "s/\s+,/,/g" #{path}`
      `#{sed} -i "s/(\r|\032)$//g" #{path}`
      # `#{sed} -i "s/(,\r|\032)/,/g" #{path}`
    end
  end

  # Correct hanging columns that are sometimes present.
  #
  # @param [Hash] options
  # @param [String] path
  def fix_columns(path, options = {})
    run_step "Fixing columns" do
      if options[:strip_commas]
        `#{sed} -i "s/([^,]),$/\\1/g" #{path}`
      end

      if options[:extra_commas]
        `#{sed} -i "s/(.),$/\\1/g" #{path}`
      end

      `#{sed} -i 's/,\\\\\,/,,/g' #{path}`
    end
  end

  # Remove the header row in a file.
  #
  # @param [Hash] options
  # @param [String] path
  def remove_header(path, options = {})
    run_step "Dropping provided header" do
      `#{sed} '1d' -i #{path}`
    end
  end

  # Format dates for direct import into a PostgreSQL database.
  #
  # @param [Hash] options
  # @param [String] path
  def format_dates(path, options = {})
    format = options[:date_format]

    run_step "Formatting dates for native conversion (#{format})" do
      case format
      when "YYYYMMDD"
        `#{sed} -i "s#,([1-2]{1}[0-9]{3})([0-9]{2})([0-9]{2})#,\\2\/\\3/\\1#g" #{path}`
      when "MMDDYYYY"
        `#{sed} -i "s#,([0-9]{2})([0-9]{2})([1-2]{1}[0-9]{3})#,\\3\/\\1/\\2#g" #{path}`
      when "MMYYYY"
        `#{sed} -i "s#,([0-9]{2})([1-2]{1}[0-9]{3})#,\\2\/01\/\\1#g" #{path}`
      end
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

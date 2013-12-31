require 'yajl'
require 'csv'

module FaaData::ConversionUtilities
  extend self

  def run_step(step, &block)
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

  def prepare_for_import(original_path, fields)
    puts "Preparing #{original_path} for import"

    path = "#{original_path}.working"
    FileUtils.cp(original_path, path)

    compress_whitespace(path)
    extract_header(path)
    escape_quotes(path)
    format_dates(path)

    yield path

  ensure
    # FileUtils.rm path if File.exists?(path)
  end

  def escape_quotes(path)
    run_step "Escaping quotes" do
      `sed -r -i "s/\\"/\\\"/g" #{path}`
    end
  end

  def compress_whitespace(path)
    run_step "Compressing whitespace" do
      `sed -r -i "s/\s+,/,/g" #{path}`
      `sed -r -i "s/(,\r|\032)//g" #{path}`
      `sed -i 's/,\\\\\,/,,/g' #{path}`
    end
  end

  def extract_header(path)
    header = `head -n 1 #{path}`
    run_step "Dropping provided header" do
      `sed '1d' -i #{path}`
    end

    header
  end

  def format_dates(path)
    run_step "Formatting dates for native conversion" do
      `sed -r -i "s#,([1-2]{1}[0-9]{3})([0-9]{2})([0-9]{2})#,\\2\/\\3/\\1#g" #{path}`
    end
  end

  def import_date_from_name(name)
    Time.zone.local_to_utc(DateTime.strptime(name.gsub('AR', ''), '%m%Y'))
  end

  def get_file_path(folder_path, file_name)
    file_path = File.expand_path(folder_path + "/#{file_name}")
    File.exists?(file_path) ? file_path : file_path + ".txt"
  end
end

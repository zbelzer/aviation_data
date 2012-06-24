require 'yajl'
require 'csv'

module AviationData
  module ConversionUtilities
    extend self

    def prepare_for_import(original_path, fields)
      puts "Preparing #{original_path} for import"

      path = "#{original_path}.working"
      FileUtils.cp(original_path, path)

      compress_whitespace(path)
      extract_header(path)
      # prepend_n_number(path)
      escape_quotes(path)
      format_dates(path)
      
      # csv_to_json(path, fields)
      path
    end

    def escape_quotes(path)
      OutputUtilities.run_step "Escaping quotes" do
        `sed -r -i "s/\\"/'/g" #{path}`
      end
    end

    def prepend_n_number(path)
      OutputUtilities.run_step "Prepending N to identifiers" do
        `sed -r -i "s/^(.*)/N\\1/g" #{path}`
      end
    end

    def compress_whitespace(path)
      OutputUtilities.run_step "Compressing whitespace" do
        `sed -r -i "s/\s+,/,/g" #{path}`
        `sed -r -i "s/(,\r|\032)//g" #{path}`
        `sed -i 's/,\\\\\,/,,/g' #{path}`
      end
    end

    def extract_header(path)
      header = `head -n 1 #{path}`
      OutputUtilities.run_step "Dropping provided header" do
        `sed '1d' -i #{path}`
      end

      header
    end

    def format_dates(path)
      OutputUtilities.run_step "Formatting dates for native conversion" do
        `sed -r -i "s#,([1-2]{1}[0-9]{3})([0-9]{2})([0-9]{2})#,\\2\/\\3/\\1#g" #{path}`
        # `sed -r -i "s/,([0-9]{2})([0-9]{4})/,\\1 01 \\2/g" #{path}`
      end
    end

    def hash_from_row(headers, row)
      Hash[*headers.zip(row).flatten(1)].tap do |data|
      end
    end

    def csv_to_json(path, fields)
      json_path = "#{path.split('.').first}.json"
      encoder = Yajl::Encoder.new

      OutputUtilities.run_step "Converting to JSON" do
        File.open(json_path, 'w') do |f|
          CSV.foreach(path) do |row|
            hash = hash_from_row(fields, row)
            encoder.encode(hash, f)
            f.write("\n")
            # break
          end
        end
      end

      json_path
    end

    def import_date_from_name(name)
      Time.zone.local_to_utc(DateTime.strptime(name.gsub('AR', ''), '%m%Y'))
    end

    def get_file_path(folder_path, file_name)
      file_path = File.expand_path(folder_path + "/#{file_name}")
      File.exists?(file_path) ? file_path : file_path + ".txt"
    end
  end
end

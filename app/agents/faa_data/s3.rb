require 'right_aws'

class FaaData::S3
  BUCKET = 'data.copilot.aero'
  KEYNAME = 'faa'

  def self.upload(opts={})
    existing_files = files.empty? ? [] : files.map {|x| x[:name]}
    new_files = Dir[File.join(AIRCRAFT_DIR, "*.zip")]

    new_files.each do |file_name|
      if existing_files.include?(File.basename(file_name)) && !opts.fetch(:force, false)
        puts "#{file} exists at #{BUCKET}. Use :force => true to upload anyway."
        next
      end

      print_now "Uploading #{file_name}... "
      s3.put(BUCKET, "#{KEYNAME}/#{File.basename(file_name)}", File.open(file_name))
      puts "Done!"
    end
  end

  def self.download(key=nil)
    `mkdir -p #{AIRCRAFT_DIR}` unless File.directory?(AIRCRAFT_DIR)

    files_to_download = key.blank? ? files : [key]

    files_to_download.each do |pair|
      next unless download_path = File.join(AIRCRAFT_DIR, pair[:name])

      File.open(download_path, "w+") do |file|
        print_now "Downloading #{pair[:name]}... "

        s3.get(BUCKET, pair[:key]) do |data|
          file.write data
        end
      end

      puts "Done!"
    end

  end

  def self.list
    puts "Listing files at #{BUCKET}"
    files.each do |pair|
      puts "Name: #{pair[:name]} Key: #{pair[:key]}"
    end
  end

  private

  def self.s3
    @s3 ||= RightAws::S3Interface.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'], {:multi_thread => true})
  end

  def self.files
    s3.list_bucket(BUCKET, :prefix => KEYNAME).inject([]) do |files, file|
      key = file[:key]
      files << {:key => key, :name => File.basename(key)}
      files
    end
  end

  def self.print_now(msg)
    print msg
    STDOUT.flush
  end
end

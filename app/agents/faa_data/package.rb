require 'open-uri'
require 'fileutils'
require 'zip/zipfilesystem'
require 'zlib'

class FaaData::Package
  WEBSITE_URL = "http://www.faa.gov/licenses_certificates/aircraft_certification/aircraft_registry/releasable_aircraft_download"

  def initialize(zipped_directory)
    @zipped_directory = zipped_directory
    @directory = zipped_directory.gsub("\.zip", "")
  end

  def extract
    FileUtils.mkdir_p(@directory)

    Zip::ZipFile::open(@zipped_directory) do |zf|
      zf.each do |e|
        fpath = File.join(@directory, File.basename(e.name))
        zf.extract(e, fpath)
      end
    end
  end

  def directory
    extract unless File.directory?(@directory)
    @directory
  end

  def name
    File.basename(@directory)
  end

  def get_file(filename)
    extract unless File.directory?(@directory)
    File.join(@directory, filename)
  end

  def self.find_packages
    raise "The directory '#{AIRCRAFT_DIR}' does not exists" unless File.directory?(AIRCRAFT_DIR)

    files = Dir.glob("#{AIRCRAFT_DIR}/*.zip").sort do |a, b|
      a = File.basename(a)
      b = File.basename(b)

      left = (a[4, 4] + a[2, 2])
      right = (b[4, 4] + b[2, 2])

      left <=> right
    end

    files.map {|dir| Package.new(dir)}
  end

  def self.download_latest
    site = open(WEBSITE_URL).read
    download_url = site.scan(/http:\/\/registry.faa.gov\/database.*\.zip/).first
    filename = download_url.scan(/AR.*\.zip/).first

    destination_path = File.join(AIRCRAFT_DIR, filename)

    FileUtils.mkdir_p(destination_path) unless File.directory?(destination_path)
    if File.exists?(destination_path)
      puts "Already have latest download"
    else
      puts "Downloading #{download_url} to #{filename}"
      open(destination_path, "w").write(open(download_url).read)
    end
  end
end

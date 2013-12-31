require 'open-uri'
require 'fileutils'
require 'zlib'

class FaaData::Package
  module VERSION
    OLD = 'OLD'
    NEW = 'NEW'
  end

  WEBSITE_URL = "http://www.faa.gov/licenses_certificates/aircraft_certification/aircraft_registry/releasable_aircraft_download"

  def initialize(path)
    path = FaaData::Package.root.join(path).to_s
    @directory = Pathname.new(path.gsub(/\.zip\Z/, ''))
  end

  def name
    @name ||= @directory.basename.to_s
  end

  def import_date
    return @import_date if @import_date

    name =~ /AR(\d{2})(\d{4})/
    @import_date = Date.new($2.to_i, $1.to_i)
  end

  def version
    import_date > Date.new(2011, 6) ? VERSION::NEW : VERSION::OLD
  end

  def directory
    extract
    @directory
  end

  def extracted?
    @directory.directory?
  end

  def extract
    return if extracted?

    FileUtils.mkdir_p(@directory)

    zipped_directory = @directory.join(".zip")
    unless zipped_directory.exists?
      raise "No zip version for #{name}, cannot decompress"
    end

    Zip::ZipFile::open(zipped_directory) do |zf|
      zf.each do |e|
        fpath = File.join(@directory, File.basename(e.name))
        zf.extract(e, fpath)
      end
    end
  end

  def find_file(name)
    extract

    if version == VERSION::OLD
      @directory.join(name.upcase)
    else
      @directory.join("#{name.upcase}.txt")
    end
  end

  def self.find
    raise "The directory '#{root}' does not exists" unless root.directory?

    files = Dir.glob(root.join("AR*")).sort do |a, b|
      a = File.basename(a)
      b = File.basename(b)

      left = (a[4, 4] + a[2, 2])
      right = (b[4, 4] + b[2, 2])

      left <=> right
    end

    files.map {|dir| FaaData::Package.new(dir)}
  end

  def self.download_latest
    site = open(WEBSITE_URL).read
    download_url = site.scan(/http:\/\/registry.faa.gov\/database.*\.zip/).first
    filename = download_url.scan(/AR.*\.zip/).first

    destination_path = root.join(filename)

    if destination_path.exists?
      puts "Already have latest download or file with same name exists"
    else
      FileUtils.mkdir_p(destination_path)

      puts "Downloading #{download_url} to #{filename}"
      open(destination_path, "w").write(open(download_url).read)
    end
  end

  def self.root
    Rails.root.join("db/data/aircraft")
  end
end

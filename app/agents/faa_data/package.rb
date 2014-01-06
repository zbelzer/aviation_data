require 'open-uri'
require 'fileutils'
require 'zlib'

# Represents a 'Releasable Aircraft Database Download' package.
class FaaData::Package
  # Version identifiers for different variations of headers.
  module VERSION
    # :nodoc:
    V1 = 'V1'
    # :nodoc:
    V2 = 'V2'
    # :nodoc:
    V3 = 'V3'
  end

  # Location of new data files.
  WEBSITE_URL = "http://registry.faa.gov/database"

  def initialize(path)
    path = FaaData::Package.root.join(path).to_s
    @directory = Pathname.new(path.gsub(/\.zip\Z/, ''))
  end

  # Shorthand name of the package. Usually 'ARMMYYYY'
  #
  # @return [String]
  def name
    @name ||= @directory.basename.to_s
  end

  # Date for which the package represents 'current' information.
  #
  # @return [Date]
  def import_date
    return @import_date if @import_date

    name =~ /AR(\d{2})(\d{4})/
    @import_date = Date.new($2.to_i, $1.to_i)
  end

  # The inferred version of the package.
  #
  # @return [String]
  def version
    if import_date <= Date.new(2011, 6)
      VERSION::V1
    elsif import_date < Date.new(2012, 11)
      VERSION::V2
    else
      VERSION::V3
    end
  end

  # Directory of extracted package.
  #
  # @return [Pathname]
  def directory
    extract
    @directory
  end

  # Has this package been extracted yet?
  #
  # @return [Boolean]
  def extracted?
    @directory.directory?
  end

  # Find a file within the package by the given name.
  #
  # @param [Name]
  # @return [Pathname]
  def find_file(name)
    extract

    path = @directory.join(name.upcase)
    unless path.exist?
      path = @directory.join("#{name.upcase}.txt")
    end

    path
  end

  # Extract the contents of the package into a directory.
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
  private :extract

  # Find all packages.
  #
  # @return [Array<Package>]
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

  # Download the latest package from the FAA website.
  def self.download_latest
    filename    = current_name
    zipname     = "#{filename}.zip"
    remote_path = File.join(WEBSITE_URL, zipname)
    local_path  = Aircrafts.root.join(zipname)

    if local_path.exist?
      false
    else
      if data = download_url(remote_path)
        File.open(local_path, "w:binary") { |f| f.write(data) }

        true
      else
        false
      end
    end
  end

  # Download data at a given url but do not attempt to follow a redirect.
  #
  # @param [String] url
  # @return [String,Nil]
  def self.download_url(url)
    open(url, :redirect => false).read
  rescue OpenURI::HTTPRedirect
    nil
  end

  # Guess the current name of the FAA package.
  #
  # @return [String]
  def self.current_name
    Date.today.strftime("AR%m%Y")
    "AR122013"
  end
end

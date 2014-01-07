require 'open-uri'
require 'fileutils'
require 'zip'

# Represents a 'Releasable Aircraft Database Download' package.
class FaaData::Package

  # Location of new data files.
  WEBSITE_URL = "http://registry.faa.gov/database"

  def initialize(path)
    path = root.join(path).to_s
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

    name =~ /#{self.class.prefix}(\d{2})(\d{4})/
    @import_date = Date.new($2.to_i, $1.to_i)
  end

  # The inferred version of the package.
  #
  # @return [String]
  def version
    nil
  end

  # Directory of extracted package.
  #
  # @return [Pathname]
  def directory
    extract
    @directory
  end

  # Directory of compressed package.
  #
  # @return [Pathname]
  def compressed_directory
    Pathname.new("#{@directory}.zip")
  end

  # Has this package been extracted yet?
  #
  # @return [Boolean]
  def extracted?
    @directory.directory?
  end

  # Find a file within the package by the given name.
  #
  # @param [Name] name
  # @return [Pathname]
  def find_file(name)
    extract
    path = nil

    ['', '.csv', '.txt'].each do |extension|
      path = @directory.join("#{name.upcase}#{extension}")
      break if path.exist?
    end

    path
  end

  # Extract the contents of the package into a directory.
  def extract
    return if extracted?

    FileUtils.mkdir_p(@directory)

    unless compressed_directory.exist?
      raise "No zip version for #{name}, cannot decompress"
    end

    Zip::File::open(compressed_directory) do |zf|
      zf.each do |e|
        fpath = File.join(@directory, File.basename(e.name))
        zf.extract(e, fpath)
      end
    end
  end
  private :extract

  # Instance method access to class' root.
  #
  # @return [Pathname]
  def root
    self.class.root
  end
  private :root

  # Find all packages.
  #
  # @return [Array<Package>]
  def self.find
    raise "The directory '#{root}' does not exist" unless root.directory?

    paths = Dir.glob(root.join("#{prefix}*"))
    paths.uniq! { |p| File.basename(p, '.zip') }
    paths.sort! do |a, b|
      a = File.basename(a)
      b = File.basename(b)

      left = (a[4, 4] + a[2, 2])
      right = (b[4, 4] + b[2, 2])

      left <=> right
    end

    paths.map {|dir| new(dir)}
  end

  # Download the latest package from the FAA website.
  def self.download_latest
    filename    = current_name
    zipname     = "#{filename}.zip"
    remote_path = File.join(WEBSITE_URL, zipname)
    local_path  = root.join(zipname)

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
    Date.today.strftime("#{prefix}%m%Y")
  end
end

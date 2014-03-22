# Find an Airport in the database.
class AviationData::Aircrafts::FindAircraft
  include Wisper::Publisher

  # @param options [Hash]
  # @option options [String] :identifier
  # @option options [DateTime] :date
  def initialize(options)
    @identifier = options[:identifier]
    @date       = options[:date]
  end

  # Execute the search and run callbacks.
  def run
    if aircraft = find_aircraft
      publish(:success, aircraft)
    else
      publish(:failure)
    end
  end

  # Find the most recent Aircraft match for an identifier given an identifier
  # and an optional point in time.
  #
  # @return [Aircraft]
  def find_aircraft
    relation =
      Aircraft.
      joins(:identifier).
      where(identifiers: {code: identifier}).
      order("as_of ASC")

    relation = relation.where("as_of <= ?", @date) if @date
    relation.last
  end

  # Get a normalized identifier to find.
  #
  # @return [String]
  def identifier
    @identifier.starts_with?("N") ? @identifier[1..-1] : @identifier
  end
end

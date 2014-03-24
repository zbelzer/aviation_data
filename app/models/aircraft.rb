# Aircrafts available for lookup.
#
# More than one aircraft with the same identifier can exist, but it may not
# exist with a different model during the same period. This represents
# identifiers being reused over time as tail numbers on different aircraft.
class Aircraft < ActiveRecord::Base
  belongs_to :model
  belongs_to :identifier

  delegate \
    :manufacturer_name,
    :model_name,
    :aircraft_type,
    :aircraft_category,
    :builder_certification,
    :engines,
    :seats, 
    :weight,
    :cruising_speed,
    :engine_type, :to => :model

  delegate :code, :to => :identifier

  # @return [String]
  def code
    identifier_code = identifier.code

    if identifier.identifier_type === :n_number
      "N#{identifier_code}"
    else
      identifier_code
    end
  end

  # Find the date corresponding to the last imported package.
  # @return [DateTime]
  def self.last_import_date(identifier = nil)
    if identifier
      joins(:identifier).
        where(identifiers: {code: identifier}).
        maximum(:as_of)
    else
      maximum(:as_of)
    end
  end
end

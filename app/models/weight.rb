# Possible weights of aircraft as defined by the FAA.
class Weight < ActiveRecord::Base
  acts_as_enumerated

  # Render this just as the name for the JSON representation.
  #
  # @return [String]
  def as_json(options = {})
    name
  end

  class << self
    # Override the enumeration lookup so we can handle the occasional
    # short-hand that the FAA uses.
    #
    # @example: '01' => 'CLASS 1'
    #
    # @return [Weight]
    def [](*args)
      if args.first =~ /^0{1,2}(\d)/
        super($1.to_i - 1)
      else
        super(*args)
      end
    end
  end
end

class Weight < ActiveRecord::Base
  acts_as_enumerated

  class << self
    def [](*args)
      if args.first =~ /^0{1,2}(\d)/
        super($1.to_i - 1)
      else
        super(*args)
      end
    end
  end
end

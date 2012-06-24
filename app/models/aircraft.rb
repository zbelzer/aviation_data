class Aircraft < ActiveRecord::Base
  has_enumerated :identifier
end

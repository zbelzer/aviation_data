# Classifications for identifiers.
# * n_number
class IdentifierType < ActiveRecord::Base
  acts_as_enumerated
end

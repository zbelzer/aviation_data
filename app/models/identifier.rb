# N-Numbers and similar identifiers imported from the FAA.
class Identifier < ActiveRecord::Base
  has_enumerated :identifier_type
end

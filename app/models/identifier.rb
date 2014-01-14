# N-Numbers and similar identifiers imported from the FAA.
class Identifier < ActiveRecord::Base
  has_enumerated :identifier_type

  # Alias for ActiveAdmin.
  # @return [String]
  def name
    code
  end
end

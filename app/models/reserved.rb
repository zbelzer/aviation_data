# Records that indicate reservations for aircraft identifiers.
#
# Per documentation:
# "This file contains names and addresses of persons and/or companies who have
# reserved the Aircraft Registration N-number. File is in N-number sequence"
#
class Reserved < ActiveRecord::Base
  set_table_name 'reserved'
end

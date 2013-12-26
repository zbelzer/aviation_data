module Core
  module Behaviors
    module Extensions
      # Minor extension for Rails' +has_one+ association that will help
      # dealing with current record assignment.
      module HasCurrentExtension
        # Sets 'is_current' flag of overridden record to false, instead
        # of deleting it or setting foreign key to nil.
        def remove_target!(*)
          if target.new_record?
            target.is_current = false
          else
            target.update_attribute(:is_current, false)
          end
        end
      end
    end
  end
end

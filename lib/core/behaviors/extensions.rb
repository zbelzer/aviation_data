module Core
  module Behaviors
    # Extends the default Rails +has_one+ and +belongs_to+ associations
    # to enable tracked and aggregated behaviors.
    module Extensions
      extend ActiveSupport::Concern
      extend ActiveSupport::Autoload

      autoload :HasAggregatedExtension
      autoload :HasCurrentExtension
      autoload :DelegateAssociated

      # :nodoc:
      module ClassMethods
        # Adds special delegation for +has_aggregated+ association to Rails'
        # +belongs_to+ reflection object.
        def extend_has_aggregated_reflection(reflection)
          HasAggregatedExtension::Helper.new(self, reflection).extend
        end
        private :extend_has_aggregated_reflection
      end

      # Overrides Rails' default #association method to extend resulting
      # +association+ objects by custom behaviors.
      def association(name)
        association = super
        reflection = self.class.reflect_on_association(name)
        case reflection.macro
        when :belongs_to
          association.extend(HasAggregatedExtension) if reflection.options[:aggregated]
        when :has_one
          association.extend(HasCurrentExtension) if reflection.options[:is_current]
        else # do nothing
        end
        association
      end
    end
  end
end

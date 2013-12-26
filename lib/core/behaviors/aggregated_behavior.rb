module Core
  module Behaviors
    # Adds aggregated behavior to a model. An aggregated model tries to insure
    # it will not duplicate itself for whatever parents it belongs to. Whenever
    # an aggregated model is about to be saved, it uses its attributes to
    # perform a lookup for an existing record with the same attributes. If the
    # lookup succeeds, its id is used to replace id of model being saved, and
    # no 'INSERT' statement is executed. If the lookup fails, the original AR
    # save routines are performed.
    module AggregatedBehavior
      # specifies a list of attributes to exclude from lookup
      NON_CONTENT_COLUMNS = %w(id created_at updated_at lock_version)

      # Override the original AR::Base #save method with the aggregated
      # behavior. This cannot be done using a before_save callback, because, if
      # the lookup succeeds, we don't want the original #save to be executed.
      # But if +false+ is returned by the callback, it will also be returned
      # by the #save method, wrongly indicating the result of saving.
      def save(*)
        @updated_as_aggregated = false
        run_callbacks(:save) do
          return (lookup_self_and_replace or super) if new_record?

          if changed?
            to_new_record!
            lookup_self_and_replace or return super
          end
          true
        end
      end

      # Use the +lookup_relation+ to get the very first existing record that
      # corresponds to +self+.
      def lookup_self
        lookup_relation.first
      end
      private :lookup_self

      # Use the attributes of +self+ to generate a relation that corresponds to
      # the existing record in the table with the same attributes.
      def lookup_relation
        self.class.unscoped.where(attributes.except(*NON_CONTENT_COLUMNS))
      end
      private :lookup_relation

      # If #lookup_self successfully returns a record, 'replace' +self+ by it
      # (using its id, created_at, updated_at values).
      def lookup_self_and_replace
        @updated_as_aggregated = true
        existing               = lookup_self

        if existing.present? then
          to_persistent!(existing)
        end
      end
      private :lookup_self_and_replace
    end
  end
end

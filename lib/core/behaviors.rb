module Core
  # Introduces Aggregated and Tracked behavior to ActiveRecord::Base models, as well
  # as Macros and Extensions modules for more efficient usage. Effectively replaces
  # both Aggregatable and Trackable modules.
  module Behaviors
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    autoload :AggregatedBehavior
    autoload :AggregatedCacheBehavior
    autoload :TrackedBehavior
    autoload :Macros
    autoload :Extensions

    included do
      include Extensions
      extend Macros
    end

    # :nodoc:
    module ClassMethods
      # Adds aggregated behavior to a model.
      def acts_as_aggregated(options = {})
        options.assert_valid_keys(:cache_by)
        include AggregatedBehavior
        if options[:cache_by].present?
          @aggregated_caching_column = options[:cache_by]
          include AggregatedCacheBehavior
        end
      end
      private :acts_as_aggregated

      # Adds tracked behavior to a model
      def acts_as_tracked
        include TrackedBehavior
      end
      private :acts_as_tracked

      # Return +true+ if self was declared as +acts_as_aggregated+.
      def acts_as_aggregated?
        self < AggregatedBehavior
      end

      # Return +true+ if self was declared as +acts_as_tracked+.
      def acts_as_tracked?
        self < TrackedBehavior
      end
    end

    # Marks +self+ as a new record. Sets +id+ attribute to nil, but memorizes
    # the old value in case of exception.
    def to_new_record!
      store_before_to_new_record_values
      reset_persistence_values
      @new_record = true
    end

    # Marks +self+ as persistent record. If another record is passed, uses its
    # persistence attributes (id, timestamps). If nil is passed as an argument,
    # marks +self+ as persisted record and sets +id+ to memorized value.
    def to_persistent!(existing = nil)
      if existing
        self.id         = existing.id
        self.created_at = existing.created_at if respond_to?(:created_at)
        self.updated_at = existing.updated_at if respond_to?(:updated_at)
        @changed_attributes = {}
      else
        restore_before_to_new_record_values
      end
      @new_record = false
      true
    end

    # Helper method used by has_aggregated (in fact, belongs_to)
    # association during autosave.
    def updated_as_aggregated?
      !!@updated_as_aggregated
    end

    # Save persistence values of id, updated_at and created_at to instance
    # variable to have an ability to set them back if object fails to
    # be saved.
    def store_before_to_new_record_values
      values = {:id => id}
      values[:updated_at] = updated_at if respond_to?(:updated_at)
      values[:created_at] = created_at if respond_to?(:created_at)
      @_before_to_new_record_values = values
    end
    private :store_before_to_new_record_values

    # Set persistence values of id, updated_at and created_at back.
    def restore_before_to_new_record_values
      values = @_before_to_new_record_values
      self.id = values[:id]
      self.created_at = values[:created_at] if respond_to?(:updated_at=)
      self.updated_at = values[:updated_at] if respond_to?(:updated_at=)
    end
    private :restore_before_to_new_record_values

    # Set id, updated_at and created_at to nil in order to
    # update them when new record is created.
    def reset_persistence_values
      self.id = nil
      self.updated_at = nil if respond_to?(:updated_at=)
      self.created_at = nil if respond_to?(:created_at=)
    end
    private :reset_persistence_values
  end
end

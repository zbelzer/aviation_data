module Core
  module Behaviors
    # This module provides additional in-memory caching for model that
    # behaves in aggregated way. For that reason, <tt>:aggregated_records_cache</tt>
    # hash class instance variable is added, and the <tt>@aggregated_caching_column</tt>
    # class instance variable should be defined by class. The value of
    # corresponding attribute of the model is used as a cache key.
    #
    # The original +lookup_self+ method is overloaded to lookup in cache
    # first. If this lookup fails, native aggregated routines are performed
    # and resulting record is added to the cache.
    #
    # Please note that this module is not to be included manually. Use
    # class-level +acts_as_aggregated+ instead, supplied with an <tt>:cache_by</tt>
    # option:
    #
    #   class EmailDomain < ActiveRecord::Base
    #     acts_as_aggregated :cache_by => :domain
    #     # .. rest of definition
    #   end
    module AggregatedCacheBehavior
      extend ActiveSupport::Concern

      # Raised when trying to include the module to a non-aggregated model.
      NotAggregatedError = Class.new(::ArgumentError)

      included do
        unless self < AggregatedBehavior
          raise NotAggregatedError, 'AggregatedCache can be used only in Aggregated models'
        end

        class_attribute :aggregated_records_cache
        self.aggregated_records_cache = {}

        after_save :cache_aggregated_record, :on => :create
      end

      # Class methods for model that includes AggregatedCacheBehavior
      module ClassMethods
        # Empty the cache of aggregated records.
        def clear_cache
          self.aggregated_records_cache = {}
        end

        # Return the column (attribute). Its value is used as a key for
        # caching records.
        def aggregated_caching_column
          @aggregated_caching_column
        end
      end

      # Overridden for caching support.
      def lookup_self
        cache = self.class.aggregated_records_cache
        cache_by = caching_attribute
        return cache[cache_by] if cache.key? cache_by
        lookup_result = super
        cache[cache_by] = lookup_result if lookup_result
        lookup_result
      end
      private :lookup_self

      # Cache the record.
      def cache_aggregated_record
        cache_by = caching_attribute
        self.class.aggregated_records_cache[cache_by] = dup.tap{ |d| d.to_persistent!(self); d.freeze }
      end
      private :cache_aggregated_record

      # Return the value of the caching column (attribute) used as a key of
      # the records cache.
      def caching_attribute
        read_attribute(self.class.aggregated_caching_column)
      end
      private :caching_attribute
    end
  end
end

module Core
  module Behaviors
    # Adds tracked behavior to a model. A tracked model should have an
    # 'is_current' boolean column. Whenever the changed tracked object is about
    # to be saved, it memorizes its id, marks itself as a new record, and then
    # allows ActiveRecord to save it via standard means. If the record was
    # successfully saved, the memorized id is used to update the 'is_current'
    # flag for the effectively replaced record.
    module TrackedBehavior
      extend ActiveSupport::Concern

      included{ around_save :tracked_save_callback }

      # The main callback for tracked behavior (see module description). Note
      # that since AR objects are saved in transaction via AR::Transactions
      # module, no self.class.transaction{} block is used here. If an exception
      # has been raised during execution, the record returns to its persisted
      # state with its old id.
      def tracked_save_callback
        if content_changed? && persisted?
          to_new_record!
          begin
            # SQL UPDATE statement is executed in first place to prevent
            # crashing on uniqueness constraints with 'is_current' condition.
            yield if update_current
          ensure
            to_persistent! if new_record?
          end
        else
          yield
        end
      end
      private :tracked_save_callback

      # Return true if any of the columns except 'is_current' has been changed.
      def content_changed?
        changed? && changes.keys != ['is_current']
      end
      private :content_changed?

      # Executes SQL UPDATE statement that sets value of 'is_current' attribute to false for a
      # record that is subject to update. If the record has locking column, will support
      # optimistic locking behavior.
      def update_current
        statement = current_to_false_sql_statement
        affected_rows = self.class.connection.update statement
        unless affected_rows == 1
          raise ActiveRecord::StaleObjectError, "Attempted to update a stale object: #{self.class.name}"
        end
        true
      end
      private :update_current

      # Generate an arel statement to update the 'is_current' state of the
      # record to false. And perform the very same actions AR does for record
      # update, but using only a single 'is_current' column.
      #
      # Note: the more efficient #current_to_false_sql_statement method is
      # used instead. This is left in comments "for some future performance
      # miracle from the arel devs" (c Bruce) --a.kuzko 2012-03-07
      # def current_to_false_arel_statement
      #   klass = self.class
      #   self.is_current = false
      #   current_attribute = arel_attributes_values(false, false, ['is_current'])
      #   stmt = klass.unscoped.where(klass.arel_table[klass.primary_key].eq(id)).arel.compile_update(current_attribute)
      #   self.is_current = true
      #   stmt
      # end
      # private :current_to_false_arel_statement

      # Generate SQL statement to be used to update 'is_current' state of record to false.
      def current_to_false_sql_statement
        klass = self.class
        lock_col = klass.locking_column
        lock_value = respond_to?(lock_col) && send(lock_col).to_i
        "UPDATE #{klass.quoted_table_name} SET \"is_current\" = #{klass.quote_value(false)} ".tap do |sql|
          sql << ", #{klass.quoted_locking_column} = #{klass.quote_value(lock_value + 1)} " if lock_value
          sql << "WHERE #{klass.quoted_primary_key} = #{klass.quote_value(@_before_to_new_record_values[:id])} "
          sql << "AND #{klass.quoted_locking_column} = #{klass.quote_value(lock_value)}" if lock_value
        end
      end
      private :current_to_false_sql_statement
    end
  end
end

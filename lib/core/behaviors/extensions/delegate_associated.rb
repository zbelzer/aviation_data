module Core
  module Behaviors
    module Extensions
      # This module is included by the class on the first call to
      # +delegate_associated+ method. When included, it will add
      # +classes_delegating_to+ class attribute to memorize classes
      # of delegated associations. This information will be used
      # for multi-parameter attributes assignment.
      module DelegateAssociated
        extend ActiveSupport::Concern

        included do
          class_attribute :classes_delegating_to
          self.classes_delegating_to = []
        end

        # Overloaded AR::Base method that will additionally check column
        # in delegated associations classes. Purpose:
        #
        #   class Customer < ActiveRecord::Base
        #     has_one_current :customer_info
        #
        #     delegate_associated :date_of_birth, :to => :customer_info
        #   end
        #
        #   customer = Customer.new({
        #     'date_of_birth(1i)' => '1950',
        #     'date_of_birth(2i)' => '03',
        #     'date_of_birth(3i)' => '18'
        #   })
        #
        # Here, for multi-parameter attribute assignment, Rails will try to
        # get the column class of 'date_of_birth' attribute. Since it is not
        # presented in Customer, the code will result in exception without
        # the following hook:
        def column_for_attribute(name)
          unless (column = super).nil?
            return column
          end

          self.class.classes_delegating_to.each do |klass|
            column = klass.columns_hash[name.to_s]
            return column unless column.nil?
          end
          nil
        end
      end
    end
  end
end

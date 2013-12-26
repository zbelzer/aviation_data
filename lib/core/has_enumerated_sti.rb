# This mixin allows the use of Single Table Inheritance by using a PowerEnum to designate object type.
# Example:
# You have an Apple and an Orange, both subclasses of Fruit.
# At a minimum, you would need a FruitType enum, a Fruit parent class, and an Apple and Orange subclasses.
#     class FruitType < ActiveRecord::Base
#       acts_as_enumerated
#     end
#     class Fruit < ActiveRecord::Base
#       has_enumerated_sti
#     end
#     class Apple < Fruit; end
#     class Orange < Fruit; end
# Your fruits table would then need a fruit_type_id column of type integer to hold the references to the fruit types
# lookup table.  The fruit_types table need to have an entry for each Fruit subclass you expect to instantiate.
module Core::HasEnumeratedSti
  extend ActiveSupport::Concern

  # Extends ActiveRecord::Base with the has_enumerated_sti method.
  module ClassMethods
    # Default name of inheritance column to use for enumerated STI:
    ENUMERATED_STI_COLUMN = 'enumerated_sti_column'

    # Indicates that this model is a superclass for enumerated STI.  The following options are supported.
    # * :enum_class_name - The class name of the enum used to define subclass types.  Default is ClassNameType.
    # * :foreign_key - The foreign key used by the enum reference.  Default is class_name_type_id.
    # * :enum_attribute - The name of the attribute that should be used to get the enum instance.  Default is class_name_type.
    def has_enumerated_sti(options = {})
      extend SingletonMethods

      # This needs to be redefined so the subclasses see the enumerated attributes
      # of the superclass.
      def self.enumerated_attributes
        superclass.enumerated_attributes
      end

      class_attribute :sti_config
      self.sti_config = { :enum_class_name => "#{table_name.classify}Type",
                          :foreign_key => "#{table_name.singularize}_type_id",
                          :enum_attribute => "#{table_name.singularize}_type" }
      sti_config.update(options)
      sti_config[:enum_class_name] = sti_config[:enum_class_name].to_s.classify

      begin
        sti_config[:enum_class] = sti_config[:enum_class_name].constantize
      rescue NameError
        raise LoadError, "#{sti_config[:enum_class_name]} is not defined."
      end

      # Create the enum reference.
      has_enumerated sti_config[:enum_attribute], :foreign_key => sti_config[:foreign_key],
                                                  :class_name  => sti_config[:enum_class_name]

      set_inheritance_column ENUMERATED_STI_COLUMN

      after_initialize :set_record_instance_type

      enum_attr = sti_config[:enum_attribute]
      enum_attr_eq = "#{enum_attr}="

      define_method :type do
        send(enum_attr).name
      end

      define_method :type= do |val|
        send enum_attr_eq, val
      end

      define_method :set_record_instance_type do
        self.type = self.class.to_s
      end
      
      class_eval do
        protected :set_record_instance_type
      end

    end

  end

  # Class level method overrides.  Unfortunately, Rails gives us no straightforward mechanism to hook into
  # how STI is handled.
  module SingletonMethods

    # Clear out the inheritance_column to short-circuit AR
    # We want this empty, as AR uses columns_hash when persisting records to the db.
    # We're using our enum for this.
    # See; http://apidock.com/rails/ActiveRecord/Base/columns_hash/class
    def columns_hash
      columns = super
      columns[inheritance_column] = nil
      columns
    end

    # Overriden so finder methods get the class type from the 'inheritance_column' like they expect.
    # See: http://apidock.com/rails/ActiveRecord/Base/instantiate/class
    def instantiate(record)
      enum_class = sti_config[:enum_class]
      foreign_key = sti_config[:foreign_key].to_s
      # Need to explicitly cast the id to int, because it returns as a string.
      enum_id = record[ foreign_key ].to_i
      type_enum = enum_class[ enum_id ]
      record[inheritance_column] = type_enum.name
      super
    end

    # Override the mechanism by which ActiveRecord determines STI type.
    # Undocumented API, unfortunately.  See: http://apidock.com/rails/ActiveRecord/Base/type_condition/class
    def type_condition(table = arel_table)
      sti_column = table[ sti_config[:foreign_key].to_sym ]
      sti_enum = sti_config[:enum_class]

      unless sti_enum.include?( self.name )
        raise KeyError, "#{sti_enum.name} should include #{self.name} but doesn't."
      end

      sti_ids = descendants.inject([]) do |subclass, sid|
        if sti_enum.include? subclass.name
          sid << sti_enum[subclass.name].id
        else
          raise KeyError, "#{sti_enum.name} should include #{subclass.name} but doesn't."
        end
        sid
      end
      sti_ids << sti_enum[self.name].id

      sti_column.in(sti_ids)
    end
  end

end
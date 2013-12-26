module Core
  # When included, adds alias_association public class method for aliasing
  # specific association. Association name and association-specific methods
  # will be aliased. Example:
  # 
  #   class Customer
  #     belongs_to :person_name
  #     has_many :orders
  #     alias_association :name, :person_name
  #     alias_association :bookings, :orders
  #   end
  #   
  #   Customer.reflect_on_association(:name) # => #<ActiveRecord::Reflection::AssociationReflection ...>
  #   c = Customer.includes(:bookings).first
  #   c.booking_ids # => [1, 2, 3]
  #   c.build_name(:first_name => 'John', :last_name => 'Smith') # => #<PersonName ...>
  module AliasAssociation
    extend ActiveSupport::Concern

    # Class methods for ActiveRecord::Base
    module ClassMethods
      # Aliases association reflection in reflections hash and
      # association-specific methods. See module description for example
      def alias_association(alias_name, association_name)
        if reflection = reflect_on_association(association_name)
          reflections[alias_name] = reflections[association_name]
          alias_association_methods(alias_name, reflection)
          reflection
        end
      end

      # Allows :alias option to alias belongs_to association
      def belongs_to(name, opts = {})
        alias_name = opts.delete(:alias)
        reflection = super(name, opts)
        alias_association(alias_name, name) if alias_name 
        reflection
      end

      # Allows :alias option to alias has_many association
      def has_many(name, opts = {})
        alias_name = opts.delete(:alias)
        reflection = super(name, opts)
        alias_association(alias_name, name) if alias_name 
        reflection
      end

      # Allows :alias option to alias has_one association
      def has_one(name, opts = {})
        alias_name = opts.delete(:alias)
        reflection = super(name, opts)
        alias_association(alias_name, name) if alias_name 
        reflection
      end


      # Aliases association methods for a given association reflections: creates
      # association accessors aliases (such as <tt>other</tt> and <tt>other=</tt>),
      # also aliases association-specific methods(such as <tt>build_other</tt> and
      # <tt>create_other</tt> for singular association, and <tt>other_ids</tt> and
      # <tt>other_ids=</tt> for collection association)
      def alias_association_methods(alias_name, reflection)
        association_name = reflection.name
        alias_association_accessor_methods(alias_name, association_name)
        case reflection.macro
        when :has_one, :belongs_to
          alias_singular_association_methods(alias_name, association_name)
        when :has_many, :has_and_belongs_to_many
          alias_collection_association_methods(alias_name, association_name)
        end
      end
      private :alias_association_methods

      # Aliases association accessor methods:
      # * <tt>other</tt>
      # * <tt>other=</tt>
      def alias_association_accessor_methods(alias_name, association_name)
        alias_method alias_name, association_name
        alias_method "#{alias_name}=", "#{association_name}="
      end
      private :alias_association_accessor_methods

      # Aliases singular association methods:
      # * <tt>build_other</tt>
      # * <tt>create_other</tt>
      # * <tt>create_other!</tt>
      def alias_singular_association_methods(alias_name, association_name)
        alias_method "build_#{alias_name}", "build_#{association_name}"
        alias_method "create_#{alias_name}", "create_#{association_name}"
        alias_method "create_#{alias_name}!", "create_#{association_name}!"
      end
      private :alias_singular_association_methods

      # Aliases collection association methods:
      # * <tt>other_ids</tt>
      # * <tt>other_ids=</tt>
      def alias_collection_association_methods(alias_name, association_name)
        singularized_alias_name = alias_name.to_s.singularize
        singularized_association_name = association_name.to_s.singularize
        alias_method "#{singularized_alias_name}_ids", "#{singularized_association_name}_ids"
        alias_method "#{singularized_alias_name}_ids=", "#{singularized_association_name}_ids="
      end
      private :alias_collection_association_methods
    end
  end
end

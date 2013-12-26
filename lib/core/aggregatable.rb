# = Aggregated associations
#
# When a given model +aggregates+ another, that eventually means that an +aggregated+
# model essentially is a part of a parent model, and contains data from the parent model
# stored in a normalized way. Since the +aggregated+ model stores normalized records, it
# may represent partial data for more than one model and record. Thus, an +aggregated+
# model should declare a +has_many+ association for each parent model, which itself
# declares a +belongs_to+ association internally in a +aggregates+ method call.
#
# == Normalization
#
# Since aggregated models tend to be normalized, DB lookup is performed whenever
# attributes for +aggregated+ record are passed for creating or updating of parent
# record. This lookup is performed by alias chaining <tt>accepts_nested_attributes_for</tt>
# method call.
#
# == Example
# 
#   class Customer < ActiveRecord::Base
#     aggregates :person_name, :delegate => true
#   end
#   
#   name = PersonName.create :first_name => 'John', :last_name => 'Smith'
#   
#   customer = Customer.new(
#     :person_name_attributes => {:first_name => 'John', :last_name => 'Smith'}
#   )
#   customer.person_name == name # => true
#   customer.first_name          # => 'John'
#   customer.last_name           # => 'Smith'
module Core::Aggregatable
  extend ActiveSupport::Concern

  # Class methods available to ActiveRecord::Base models.
  module ClassMethods
    # Declares +belongs_to+ association, acceptance of nested attributes for
    # association, and performs automatic lookup for associated objects.
    # * If <tt>:nested</tt> key is present in +options+, it should contain a hash
    #   that will be passed in <tt>accepts_nested_attributes_for</tt> method call.
    # * If <tt>:delegate</tt> value of +options+ has a <tt>true</tt> value, association's
    #   attribute getters will be delegated to parent record.
    #
    # == Example
    # 
    #   class Customer < ActiveRecord::Base
    #     aggregates :person_name, :delegate => true
    #   end
    #   
    #   name = PersonName.create :first_name => 'John', :last_name => 'Smith'
    #   
    #   customer = Customer.new(
    #     :person_name_attributes => {:first_name => 'John', :last_name => 'Smith'}
    #   )
    #   
    #   customer.person_name == name # => true
    #   customer.first_name          # => 'John'
    #   customer.last_name           # => 'Smith'
    def aggregates(association_name, options = {})
      options.symbolize_keys!
      delegate = options.delete(:delegate)
      options_for_nested = options.delete(:nested) || {}

      belongs_to association_name, options
      accepts_nested_attributes_for association_name, options_for_nested
      aggregated_associations << association_name.to_sym

      reflection = reflect_on_association(association_name.to_sym)
      klass = reflection.klass

      content_columns = klass.content_columns.map(&:name) - %W(created_at updated_at #{klass.locking_column})
      if delegate
        methods_to_delegate = content_columns + klass.enumerated_attributes
        options_for_delegate =  [{:to => association_name, :allow_nil => true}]
        parameters_for_delegate = methods_to_delegate + options_for_delegate
        delegate(*parameters_for_delegate)
      end
      
      alias_method "#{association_name}_attributes_without_aggregation=", "#{association_name}_attributes="
      define_method "#{association_name}_attributes=" do |*args|
        attributes = args.first || {}

        if attributes.empty? || attributes.values.all?(&:blank?)
          return send("#{association_name}_attributes_without_aggregation=", attributes)
        end

        relation = klass.relation_for_aggregated(klass.scoped, attributes)

        if existing = relation.first
          send("#{association_name}=", existing)
        else
          send("#{association_name}_attributes_without_aggregation=", attributes)
        end
      end
    end

    # Returns array of aggregated association names of a class. Array is populated when
    # +aggregates+ method is called by class, defining new aggregated association.
    def aggregated_associations
      @aggregated_associations ||= []
    end

    # Returns +true+ if +belongs_to+ association was defined by +aggregates+ method.
    def aggregates?(name)
      aggregated_associations.include?(name.to_sym)
    end

    # The most important method of aggregated association. Purpose of it is to create
    # a relation based on given attributes, SQL query of which will return an
    # appropriate record if it exists in DB.
    # 
    # To achieve this goal, +aggregates+ method calls +accepts_nested_attributes_for+
    # internally and then redefines <tt>#accociation_name#_attributes=</tt> method.
    # Thus, lookup is based on <tt>#association_name#_attributes</tt> hash passed.
    #
    # In general, +relation_for_aggregated+ handles three major aspects:
    # * +attribute+ => +value+ adds simple +where+ clause to the +relation+.
    # * if +attribute+ is one of +enum+ attributes, +value+ is used fetch +id+ of +enum+
    #   value, and then +attribute_id+ => +id+ where clause is added to relation.
    # * if association's klass being looked up relies on aggregated associations itself,
    #   +attribute+ has a form of <tt>#nested_association#_attributes</tt>, and it's
    #   +value+, which is a hash of nested parameters, is passed to association's klass'
    #   +relation_for_aggregated+ method recursively, adding association name to +joins+
    #   array passed to method call.
    #
    # == Example
    #   
    #   class Name < ActiveRecord::Base
    #     # t.string :name
    #   end
    #   
    #   class FirstName < ActiveRecord::Base
    #     # t.integer :name_id
    #     aggregates :name
    #   end
    #   
    #   class LastName < ActiveRecord::Base
    #     # t.integer :name_id
    #     aggregates :name
    #   end
    #   
    #   class PersonName < ActiveRecord::Base
    #     # t.integer :first_name_id
    #     # t.integer :last_name_id
    #     # t.string :prefix
    #     aggregates :first_name
    #     aggregates :last_name
    #   end
    #   
    #   class Customer < ActiveRecord::Base
    #     # t.integer :person_name_id
    #     # t.date :birthdate
    #     aggregates :person_name
    #   end
    #   
    #   customer_params = {
    #     'birthdate' => '1980-01-01',
    #     'person_name_attributes' => {
    #       'prefix' => 'Mr',
    #       'first_name_attributes' => {
    #         'name_attributes' => {'name' => 'John'}
    #       },
    #       'last_name_attributes' -> {
    #         'name_attributes' => {'name' => 'Smith'}
    #       }
    #     }
    #   }
    #   customer.create(customer_params)
    #
    # At this point, creation of new customer requires lookup of existing person_name,
    # which itself requires lookup of existing first_name and last_name, each of which
    # requires lookup of existing names. To make the actual person_name lookup in one
    # request, we have to perform series of +JOINS+, so the resulting SQL query should
    # look like
    # 
    #   SELECT * FROM person_names
    #   INNER JOIN first_names ON person_names.first_name_id = first_names.id
    #   INNER JOIN names ON first_names.name_id = names.id
    #   INNER JOIN last_names ON person_names.last_name_id = last_names.id
    #   INNER JOIN names last_name_names ON last_names.name_id = last_name_names.id
    #   WHERE person_names.prefix = 'Mr'
    #     AND names.name = 'John'
    #     AND last_name_names.name = 'Smith'
    #
    # Note that 'names' table was aliased in the last join to have the ability to
    # query for the right record.
    #
    # During method execution, original +relation+, which has the initial value of
    # <tt>PersonName.scoped</tt> takes series of transformations:
    # * <tt>relation = relation.where('person_names' => {'prefix' => 'Mr'})</tt>
    # * <tt>relation = relation.joins(:first_names)</tt>
    # * <tt>relation = relation.joins(:first_names => :names)</tt>
    # * <tt>relation = relation.where('names' => {'name' => 'John'})</tt>
    # * <tt>relation = relation.joins(:last_names)</tt>
    # * <tt>relation = relation.joins(:last_names => :names)</tt>
    # * <tt>relation = relation.where('names_last_names' => {'name' => 'Smith'})</tt>
    # 
    # Please note the alias for the 'names' table in the last +where+ clause. This alias
    # name is taken from the Rails-generated Arel Node of the relation.
    #
    # As the result, if no record was found, original <tt>#accociation_name#_attributes=</tt>
    # method will be called  that would create a new AR object for the association.
    def relation_for_aggregated(relation, attributes, joins = [])
      # Converting array of nested associations to a hash, that is going to be passed to
      # relation's +joins+ method, i.e. [:foo, :bar, :baz] -> {:foo => {:bar => :baz}}.
      # Note that [:foo] will result in :foo.
      unless joins.empty?
        joins_hash = joins[0...-1].reverse.inject(joins.last) do |res, item|
          {item => res}
        end
        relation = relation.joins(joins_hash)
      end

      # TODO: As the result of joining, table may get alias (if association
      #   for the same model was joined before). Following two lines of code attempt to
      #   retrieve name of table in resulting SQL query that will be fetched by Arel.
      #   Probably there should be more efficient and right way of achieving the same
      #   goal.  -- a.kuzko 2011-12-06
      arel_joins = relation.arel.ast.cores[0].source.right
      table_name = arel_joins.empty? ? self.table_name : arel_joins.last.left.name

      attributes.stringify_keys!.delete('id')

      attributes.inject(relation) do |result, (attribute, value)|
        if self.has_enumerated?(attribute)
          reflection = reflect_on_enumerated(attribute.to_sym)
          enum_id = reflection.class_name.constantize[value].try(:id)
          result.where(table_name => {reflection.foreign_key => enum_id})
        elsif attribute =~ /^(\w+)_attributes$/ && self.aggregates?($1)
          reflect_on_association($1.to_sym).klass.relation_for_aggregated(result, value, joins + [$1.to_sym])
        elsif attribute !~ /_attributes$/
          result.where(table_name => {attribute => value})
        else
          result
        end
      end
    end
  end
end

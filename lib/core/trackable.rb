# == Trackable Models
# A trackable model keeps track of its updates. Thus, whenever a tracked model
# is updated, a new superseding record is created instead, keeping the original record unchanged except for its
# +current+ flag and any changes explicitly made by the +superseded+ method.
# If the tracked tracked model tracks other models itself, superseding
# records will be created for all tracked associations recursively.
#
# Trackable behavior is defined by two major methods:
# [+tracks+] for each argument passed, which should be pluralized name of the association, this
#            method declares <tt>has_many pluralized_name</tt> association, as well as
#            <tt>has_one current_singularized_name</tt> association. It also marks association as tracked
#            for internal purposes.
# [+tracked_by+] for each association name, passed, this method declares +belongs_to+ association. It
#                also marks the association name as tracking owner of the model for internal purposes.
#                Also, it alias chains original +save+ method to add trackable behavior (only once).
#
# Each tracked model requires presence of the special boolean tracking column, which is 'is_current' by
# default. The value of this column will be automatically set to +false+ when the record is superseded.
# 
# If +superseded+ method is defined by trackable model, it will be called within the scope of
# record being superseded with an argument of successor record, as a callback.
#
# == Example
#   
#   class Customer < ActiveRecord::Base
#     tracks :employments
#   end
#   
#   class Employment < ActiveRecord::Base
#     tracked_by :customer, :current => 'is_active'
#     
#     def superseded(successor)
#       self.status = 'invalid'
#       successor.status = 'new'
#     end
#   end
# 
# In this example, +Customer+ receives
# 
# <tt>has_many :employments</tt> association, as well as
# 
# <tt>has_one :current_employment, :class_name => 'Employment', :conditions => {'is_active' => true}, :inverse_of => :customer</tt>
# (see note bellow), it also receives
#
# <tt>accepts_nested_attributes_for :current_employment</tt> for convenient form creation support.
# 
# At the same time, +Employment+ receives
# 
# <tt>belongs_to :customer, :inverse_of => :current_employment</tt>,
# and the overloaded +save+ method.
#
# *Note:* Since tracking column is defined by tracked model, the <tt>:conditions</tt> option for
# <tt>has_one :curent_employment</tt> is actually a lambda that results in <tt>{'is_active' => true}</tt>.
# 
# From this time, whenever any +Employment+ record is updated
# (thus, it is changed and valid in context of persisted record validation), successor record with
# changed attributes of original record is created, all the changes of original records are reset,
# the +superseded+ method is called, performing additional modifications for both original and
# successor records. And then, both records are saved - successor is saved as new +current_employment+
# record, and the original record is saved with updated +is_active+ attribute set to +false+, and with
# it's status set to <tt>'invalid'</tt>, since this change is performed by +superseded+ method call.
#
# == Multiple Tracking Owners
#
# It is possible for a tracked model to have multiple tracking owners. However, multiple tracking columns,
# each for one owner *are not supported*. That means that latest +tracked_by+ method call that specifies
# tracking column (via <tt>:current</tt> option) will overload previous ones:
#
#   class Employment
#     # specifying multiple tracking owners in one call:
#     tracked_by :customer, :employment_provider
#   end
#
#   class Employment
#     tracked_by :customer, :current => 'is_active' # tracking_column is set to 'is_active'
#     tracked_by :employment_provider, :current => 'is_valid' # tracking_column is set to 'is_valid'
#   end
#
# == Tracking Chain
#
# If tracked model tracks other models itself, their successors will be created as well whenever
# top-level record is superseded:
# 
#   class Employment < ActiveRecord::Base
#     tracked_by :customer
#     tracks :incomes
#   end
#   
#   class Income < ActiveRecord::Base
#     tracked_by :employment
#   
#     def superseded(successor)
#       self.is_active = false
#       successor.is_active = true
#     end
#   end
#   
#   employment = Employment.first
#   successor = employment.send(:supersede) # Since #supersede is protected method, used internally
#                                           # whenever tracked record receives +update_attributes+
#   successor.new_record?                # => true
#   successor.current_income.present?    # => true
#   successor.current_income.new_record? # => true. successor of employment.current_income
#   successor.current_income.is_active?  # => true
#   employment.current_income.changes    # => {:is_active => [true, false]}
# 
# == Optimistic Locking
#
# If the trackable model has +lock_version+ columns, this will be sufficient enough to prevent
# re-superseding of the already superseded record, because each superseding requires update of the
# tracking column (which is 'is_current' by default), and that update will also increment value of
# lock_version column. This will prevent superseding of the staled object due to Rails built-in
# Optimistic Locking support. Example:
#
#   customer1 = Customer.first
#   customer2 = Customer.first
#   
#   # preloading associations
#   customer1.spec_employment(true)
#   customer2.spec_employment(true)
#   
#   customer1.update_attributes('current_employment_attributes' => {'id' => '1', 'employer' => 'Queen Mary'}) # => true
#   customer2.update_attributes('current_spec_employment_attributes' => {'id' => '1', 'employer' => 'Queen Elizabeth'}) # => raises ActiveRecord::StaleObjectError
module Core::Trackable
  extend ActiveSupport::Concern

  # Hosts ActiveRecord::Base class extensions for trackable functionality. See Core::Trackable
  # description for details.
  module ClassMethods
    # Name of tracking column used unless otherwise specified.
    DEFAULT_TRACKING_COLUMN = 'is_current'

    # Declares tracked association. Internally, calls <tt>has_many<tt> and <tt>has_one :current_</tt>
    # methods for passed plural association name(s).
    #
    # == Parameters
    #
    # [+association_name+] one or many plural association names. Each of them will be used to create
    #                      trackable association.
    # [+options+] all options specified will be passed for +has_many+ association declaration(s). The <tt>:inverse_of</tt>
    #             option will be automatically assigned unless exists.
    #
    # == Example
    #
    #   class Customer < ActiveRecord::Base
    #     tracks :employments, :drivers_licenses
    #   end
    def tracks(*args)
      options = args.extract_options!
      options[:inverse_of] ||= name.underscore.to_sym

      args.each do |pluralized_association_name|
        has_many_reflection = has_many(pluralized_association_name, options.reverse_merge(:order => 'id DESC'))

        conditions_for_current = lambda do |_|
          {has_many_reflection.klass.tracking_column => true}
        end

        association_class_name = has_many_reflection.options[:class_name] || pluralized_association_name.to_s.singularize.camelize
        has_one_association_name = :"current_#{association_class_name.underscore}"
        options_for_has_one = {:conditions => conditions_for_current}
        options_for_has_one.merge!(:class_name => association_class_name, :inverse_of => options[:inverse_of])

        has_one(has_one_association_name, options_for_has_one)
        accepts_nested_attributes_for has_one_association_name
        tracked_associations << has_one_association_name
        redefine_association_methods(has_one_association_name)
      end
    end

    # Declares trackable behavior for model. For each association name passed, declares +belongs_to+ association.
    # If <tt>:current</tt> option is present, it is used as +tracking_column+ for a model. All other options are
    # passed to +belongs_to+ method call. Automatically assigns <tt>:inverse_of</tt> option, if none is passed.
    #
    # Alias chains +save+ method for trackable behavior (unless already chained).
    #
    # == Example
    # 
    #   class Employment
    #     tracked_by :customer, :current => 'is_active'
    #   end
    def tracked_by(*args)
      options = args.extract_options!
      options[:inverse_of] ||= :"current_#{name.underscore}"

      # @column_for_current gets default value in getter method
      @tracking_column = options.delete(:current)

      args.each do |association_name|
        belongs_to(association_name, options)
        tracking_owners << association_name
      end

      define_save_with_tracking unless save_with_tracking_defined?
    end

    # Returns array of tracked <tt>has_one :current_</tt> association names declared as being tracked
    # for a given model. Returns empty array if no associations tracked.
    def tracked_associations
      @tracked_associations ||= []
    end

    # Returns array of tracked <tt>belongs</tt> association names declared by +tracked_by+ method
    # by model. Returns empty array if model is not declared as tracked.
    def tracking_owners
      @tracking_owners ||= []
    end

    # Returns +tracking_column+ that was set by +tracked_by+ method call and passed as <tt>:current</tt>
    # option. Returns <tt>'is_current'</tt> by default.
    def tracking_column
      @tracking_column ||= DEFAULT_TRACKING_COLUMN
    end

    # Redefines <tt>current_association=</tt> method to handle direct assignment of new current
    # trackable record and set +current+ state of previous record to +false+. Delegates to
    # original functionality if owner of trackable association is a new record or current
    # trackable record is +nil+ or new one. Otherwise, calls protected +assign_current_trackable_record+
    # method.
    # 
    # Note: manual assignment will not create superseders for nested, tracked associations.
    def redefine_association_methods(association_name)
      original, aliased = "#{association_name}_without_trackable=", "#{association_name}="
      alias_method original, aliased
      redefine_method(aliased) do |successor|
        return send(original, successor) if new_record?

        assoc = association(association_name)

        old_target = assoc.load_target
        return send(original, successor) if old_target.nil? || old_target.new_record?

        assign_current_trackable_record(assoc, successor)
      end
    end
    private :redefine_association_methods

    # Defines +save_with_tracking+ method that handles successor creation on save, and chains original
    # +save+ method to it.
    def define_save_with_tracking
      define_method('save_with_tracking') do
        if new_record? || superseded?
          @superseded = nil
          return save_without_tracking
        end

        if changed?
          supersede_and_save_in_transaction if valid?
        else
          true
        end
      end
      alias_method_chain :save, :tracking
    end
    private :define_save_with_tracking

    # Returns +true+ if original +save+ method was already chained to +save_with_tracking+
    def save_with_tracking_defined?
      respond_to?(:save_with_tracking)
    end
    private :save_with_tracking_defined?
  end

  # Private method. For passed trackable association: sets +tracking_column+ for current
  # record to +false+, and +true+ to passed successor. Calls +superseded+ callback in context
  # of old record with new one as an argument. Saves records in transaction.
  def assign_current_trackable_record(association, successor)
    old_target = association.load_target
    tracking_column = self.class.tracking_column
    self.class.transaction do
      old_target.send("#{tracking_column}=", false)
      successor.send("#{tracking_column}=", true)
      old_target.superseded(successor) if old_target.respond_to?(:superseded)
      association.send(:set_owner_attributes, successor)
      if successor.save_without_tracking
        association.send(:set_inverse_instance, successor)
        association.target = successor
        old_target.save_without_tracking if old_target.changed?
      end
    end
  end
  private :assign_current_trackable_record

  # Private method. Creates a successor, then saves self and successor in single transaction
  def supersede_and_save_in_transaction
    self.class.transaction do
      successor = supersede
      save_without_tracking
      if successor.save
        assign_successor_to_owners(successor)
        true
      end
    end
  end
  private :supersede_and_save_in_transaction

  # Protected method. Creates and returns +successor+ of a record. Before returning a +successor+,
  # resets changes on original record, sets <tt>@errors</tt> instance variable on +successor+ to
  # +nil+ to re-instantiate it (since it was created with <tt>@base</tt> variable referencing to
  # original record), calls +superseded+ method if declared, and chains nested tracking associations
  # to +successor+ (see Core::Trackable, Tracking Chain)
  def supersede
    dup.tap do |successor|
      reset_changes! do
        superseded(successor) if respond_to?(:superseded)
      end
      tracking_column = self.class.tracking_column
      self.send("#{tracking_column}=", false)
      successor.send("#{tracking_column}=", true)
      successor.instance_variable_set('@errors', nil)
      supersede_tracking_chain_to(successor)
      @superseded = true
    end
  end
  protected :supersede

  # Returns +true+ if record has already been superseded. Used internally
  def superseded?
    !!@superseded
  end
  private :superseded?

  # Used to create successors of nested trackable associations. Used internally by <tt>supersede</tt>
  # method
  def supersede_tracking_chain_to(successor)
    self.class.tracked_associations.each do |association_name|
      successor.send("#{association_name}=", send(association_name).try(:supersede))
    end
  end
  private :supersede_tracking_chain_to

  # If possible, sets inverse :current_record association of the owners to newly created successor
  #
  # Example:
  #
  #   customer.current_employment # => Employment with id 1
  #   customer.update_attributes('current_employment_attributes' => {'id' => '1', 'employer' => 'Queen Mary'})
  #   customer.current_employment # => Employment with id 2 - successor of the first Employment record
  def assign_successor_to_owners(successor)
    self.class.tracking_owners.each do |association_name|
      owner_association = association(association_name)
      if owner_association.loaded?
        owner_target = owner_association.target
        successor.association(association_name).target = owner_target
        # somewhy, owner_association.set_inverse_record(successor) doesn't work
        owner_target.association(owner_association.send(:inverse_reflection_for, self).name).target = successor
      end
    end
  end
  private :assign_successor_to_owners

  # Resets changes in a record. If block is given, will yield it before reseting changes, and
  # will omit reseting changes introduced in block. But if the value changed in block was
  # also changed before the block, it will be reseted. For example:
  #   user = User.create(:name => 'John', :age => 20)
  #   user.name = 'Jack'
  #   user.age = 21
  #   user.reset_changes!
  #   user.name # => 'John'
  #   user.age  # => 20
  #   user.name = 'Jack'
  #   user.reset_changes! do
  #     user.age = 21
  #   end
  #   user.name    # => 'John'
  #   user.age     # => 21
  #   user.changes # => {'age' => [20, 21]}
  #   user.reset_changes! do
  #     user.age = 22 # this value will be reseted, since 'age' attribute is 'marked' for reset
  #   end
  #   user.age     # => 20
  #
  # Returns +self+
  def reset_changes!
    changed_attributes = changes.keys

    yield if block_given?

    unless changes.empty?
      changes.each do |attribute, (old, changed)|
        send("#{attribute}=", old) if changed_attributes.include?(attribute)
      end
    end
    self
  end
end

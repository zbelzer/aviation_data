# Shared helper methods for BatchImport utilities.
module BatchImport::Helpers
  # Attempts a block and reports an issue if there is an exception.
  #
  # @param [Symbol] field_name
  # @param [Object] record
  def try_conversion(field_name, record)
    yield
  rescue => e
    puts "Could not perform conversion on #{field_name}:"
    puts e.message
    puts record.inspect
  end

  # Attempts a convert a date and set it on the target model.
  #
  # @param [Object] source Source record for date
  # @param [Object] target Target record for converted date
  # @param [Symbol] field_name
  def set_date(source, target, field_name)
    value = source[field_name]

    unless value.blank?
      try_conversion(field_name, source) do
        target[field_name] = Date.parse(value)
      end
    end
  end

  # Attempts a find an enum by name and set it on the model. If an enum does not exist, it will create it.
  #
  # @param [Object] source Source record for date
  # @param [Object] target Target record for converted date
  # @param [Symbol] field_name
  def set_enum(source, target, field_name, enum_class)
    enum_class.enumeration_model_updates_permitted = true
    enum_field_name = "#{field_name}_id"

    try_conversion(field_name, source) do
      value = enum_class[source[field_name]]
      target[enum_field_name] = (value || enum_class.create(:name => source[field_name]))
    end

    enum_class.enumeration_model_updates_permitted = false
  end
end

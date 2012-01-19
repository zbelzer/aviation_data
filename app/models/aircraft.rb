class Aircraft
  include MongoMapper::Document

  key :value, Hash, :index => true

  ensure_index('value.identifier')
  ensure_index('value.identifier')
  ensure_index('value.model')
  ensure_index('value.type')
  ensure_index('value.category')
  ensure_index('value.engine_type')
  ensure_index('value.engines')
  ensure_index('value.seats')
end

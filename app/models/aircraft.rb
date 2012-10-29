class Aircraft < ActiveRecord::Base
  belongs_to :model
  belongs_to :identifier

  delegate \
    :manufacturer_name,
    :model_name,
    :aircraft_type,
    :aircraft_category,
    :builder_certification,
    :engines,
    :seats, 
    :weight,
    :cruising_speed,
    :engine_type, :to => :model

  delegate :code, :to => :identifier
end

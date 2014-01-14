ActiveAdmin.register Aircraft do
  filter :model_code, as: :string
  filter :identifier_code, as: :string

  filter :model_aircraft_category_id, as: :select, collection: proc { AircraftCategory.all }
  filter :model_aircraft_type_id, as: :select, collection: proc { AircraftType.all }

  index do
    column :identifier
    column :model
    column :aircraft_type do |aircraft|
      aircraft.aircraft_type.try {|type| type.name.titleize}
    end

    column :aircraft_category do |aircraft|
      aircraft.aircraft_category.try {|category| category.name.titleize}
    end
  end
end

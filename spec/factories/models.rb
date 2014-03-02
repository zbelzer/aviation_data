# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :model do
    sequence(:code)       { |n| "ABC#{n}" }
    manufacturer_name     { ManufacturerName.first }
    model_name            { ModelName.first }
    aircraft_type         { AircraftType.first }
    engine_type           { EngineType.first }
    weight                { Weight.first }
    aircraft_category     { AircraftCategory.first }
    builder_certification { BuilderCertification.first }
  end
end

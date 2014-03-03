# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :model do
    sequence(:code)       { |n| "ABC#{n}" }
    manufacturer_name     { ManufacturerName.first }
    model_name            { ModelName.first }
    aircraft_category     :land
    aircraft_type         :fixed_wing_single_engine
    engine_type           :Reciprocating
    weight                { Weight.first }
    builder_certification { BuilderCertification.first }
  end
end

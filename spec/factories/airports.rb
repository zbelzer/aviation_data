# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :airport do
    name "Los Angeles International"
    iata "LAX"
    icao "KLAX"
  end
end

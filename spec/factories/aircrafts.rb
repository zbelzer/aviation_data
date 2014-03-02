# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :aircraft do
    association :identifier
    association :model
  end
end

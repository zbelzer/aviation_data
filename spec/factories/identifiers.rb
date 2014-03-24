# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier do
    sequence(:code) { |n| n.to_s }
    identifier_type :n_number
  end
end

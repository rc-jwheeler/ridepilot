require 'faker'

FactoryGirl.define do
  factory :address do
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state "OR"
  end
end

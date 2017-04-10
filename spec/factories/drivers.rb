require 'faker'

FactoryGirl.define do
  factory :driver do
    name { Faker::Lorem.words(2).join(' ') }
    provider
    user
    association :address, factory: :driver_address
    phone_number { Faker::PhoneNumber.phone_number }
  end
end

require 'faker'

FactoryGirl.define do
  factory :vehicle do
    name { Faker::Lorem.words(2).join(' ') }
    provider
    association :default_driver, factory: :driver
  end
end

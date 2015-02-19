require 'faker'

FactoryGirl.define do
  factory :provider do
    name { Faker::Lorem.words(2).join(' ') }
  end
end

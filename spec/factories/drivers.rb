require 'faker'

FactoryGirl.define do
  factory :driver do
    name { Faker::Lorem.words(2).join(' ') }
    provider
    user
  end
end

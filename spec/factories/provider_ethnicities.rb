require 'faker'

FactoryGirl.define do
  factory :provider_ethnicity do
    provider
    name  { Faker::Lorem.words(2).join(' ') }
  end
end

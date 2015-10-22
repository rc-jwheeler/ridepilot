require 'faker'

FactoryGirl.define do
  factory :ethnicity do
    name  { Faker::Lorem.words(2).join(' ') }
  end
end

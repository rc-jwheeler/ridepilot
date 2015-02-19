require 'faker'

FactoryGirl.define do
  factory :mobility do
    name  { Faker::Lorem.words(2).join(' ') }
  end
end

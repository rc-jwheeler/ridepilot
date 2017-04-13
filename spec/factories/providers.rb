require 'faker'

FactoryGirl.define do
  factory :provider do
    name { Faker::Lorem.words(2).join(' ') }
    advance_day_scheduling 21
  end
end

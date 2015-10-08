require 'faker'

FactoryGirl.define do
  factory :customer do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    provider
    token SecureRandom.uuid
  end
end

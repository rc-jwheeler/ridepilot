require 'faker'

FactoryGirl.define do
  factory :provider do
    name { Faker::Lorem.words(2).join(' ') }
  end
  
  factory :role do
    user
    provider { user.current_provider }
    level 100
  end
  
  factory :user do
    email { Faker::Internet.email }
    password 'password#1'
    password_confirmation 'password#1'
    association :current_provider, factory: :provider
  end  
  
  factory :driver do
    name { Faker::Lorem.words(2).join(' ') }
    provider
    user
  end
  
  factory :device_pool do
    name { Faker::Company.name }
    color { SecureRandom.hex(3) }
    provider
  end
  
  factory :device_pool_driver do
    driver
    device_pool
  end

  factory :trip do
    association :pickup_address, factory: :address
    association :dropoff_address, factory: :address
    pickup_time { Time.now + 1.week }
    appointment_time { pickup_time + 30.minutes }
    trip_purpose "Medical"
    customer
  end
  
  factory :address do
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state "OR"
  end
  
  factory :customer do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    provider
  end
end

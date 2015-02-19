require 'faker'

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'password#1'
    password_confirmation 'password#1'
    association :current_provider, factory: :provider
  end
end

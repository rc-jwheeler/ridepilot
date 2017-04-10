require 'faker'

FactoryGirl.define do
  factory :address do
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state "OR"
  end

  factory :user_address, parent: :address, class: UserAddress
  
  factory :driver_address, parent: :address, class: DriverAddress

  factory :customer_common_address, parent: :address, class: CustomerCommonAddress

  factory :provider_common_address, parent: :address, class: ProviderCommonAddress
end

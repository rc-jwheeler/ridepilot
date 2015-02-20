FactoryGirl.define do
  factory :vehicle do
    provider
    association :default_driver, factory: :driver
  end
end

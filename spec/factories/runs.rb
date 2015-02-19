FactoryGirl.define do
  factory :run do
    date { Time.now }
    vehicle
    driver
    provider
  end
end

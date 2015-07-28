FactoryGirl.define do
  factory :run do
    date { Time.zone.now }
    vehicle
    driver
    provider
  end
end

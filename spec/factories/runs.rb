FactoryGirl.define do
  factory :run do
    date { Date.today }
    vehicle
    driver
    provider
  end
end

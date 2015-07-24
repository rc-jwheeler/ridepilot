FactoryGirl.define do
  factory :driver_compliance do
    driver
    event { Faker::Lorem.words(2).join(' ') }
    due_date { Date.current.tomorrow }
  end
end

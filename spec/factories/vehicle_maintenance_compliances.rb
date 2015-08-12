FactoryGirl.define do
  factory :vehicle_maintenance_compliance do
    vehicle
    event { Faker::Lorem.words(2).join(' ') }
    due_type "date"
    due_date { Date.current.tomorrow }
  end
end

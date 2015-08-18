FactoryGirl.define do
  factory :vehicle_maintenance_compliance do
    vehicle
    event { Faker::Lorem.words(2).join(' ') }
    due_type "date"
    due_date { Date.current.tomorrow }
    
    trait :recurring do
      after(:build) do |vmc|
        vmc.recurring_vehicle_maintenance_compliance = create :recurring_vehicle_maintenance_compliance, provider: vmc.vehicle.provider
      end
    end
  end
end

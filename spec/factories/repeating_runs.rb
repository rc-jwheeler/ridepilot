FactoryGirl.define do
  factory :repeating_run do
    name { Faker::Lorem.words(2).join(' ') }
    date { Date.today }
    vehicle
    driver
    provider

    # SCHEDULE ATTRS
    start_date { date } # Set the schedule start date to equal date field
    # repetition_interval 1   # Setting this messes up the recurring_ride_coordinator shared examples 
    repeats_mondays { date.monday? }
    repeats_tuesdays { date.tuesday? }
    repeats_wednesdays { date.wednesday? }
    repeats_thursdays { date.thursday? }
    repeats_fridays { date.friday? }
    repeats_saturdays { date.saturday? }
    repeats_sundays { date.sunday? }
  end
  
  trait :weekly do
    repetition_interval 1
  end
  
  trait :biweekly do
    repetition_interval 2
  end
  
  trait :triweekly do
    repetition_interval 3
  end
  
  trait :last_week do
    date { Date.today - 1.week }
  end

  trait :two_days_ago do
    date { Date.today - 2.days }
  end

  trait :yesterday do
    date { Date.yesterday }
  end

  trait :today do
    date { Date.today }
  end

  trait :tomorrow do
    date { Date.tomorrow }
  end

  trait :next_week do
    date { Date.today + 1.week }
  end
  
end

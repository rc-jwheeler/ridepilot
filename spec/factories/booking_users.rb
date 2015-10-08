FactoryGirl.define do
  factory :booking_user do
    user 
    token { Faker::Lorem.characters(16) }
    url { Faker::Internet.url }
  end

end

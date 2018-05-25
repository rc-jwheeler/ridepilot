FactoryBot.define do
  factory :message do
    type "RoutineMessage"
    body "MyText"
    associate :reader, factory: :user
    associate :sender, factory: :user
    read_at "2018-05-24 14:44:00"
  end
end

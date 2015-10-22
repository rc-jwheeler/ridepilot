FactoryGirl.define do
  factory :eligibility do
    code  {|n| "eligibility_#{n}" }
    description "MyString"
  end

end

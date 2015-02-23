require 'faker'

FactoryGirl.define do
  factory :funding_source do
    transient do
      provider nil
    end
    
    name  { Faker::Lorem.words(2).join(' ') }
    
    after(:build) do |funding_source, evaluator|
      if evaluator.provider.present? 
        Array(evaluator.provider).each do |provider|
          funding_source.funding_source_visibilities << build(:funding_source_visibility, :funding_source => funding_source, :provider => provider)
        end
      end
    end
  end
end

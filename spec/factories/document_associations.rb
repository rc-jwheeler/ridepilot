FactoryGirl.define do
  factory :document_association do
    transient do
      force_valid_owners true
    end
  
    document
    association :associable, factory: :driver_compliance

    after(:build) do |da, evaluator|
      if evaluator.force_valid_owners and da.document.present? and da.associable.present?
        # Document and associable must have the same owner
        da.associable.driver = da.document.documentable
      end
    end
  end
end

FactoryGirl.define do
  factory :document_association do
    document
    associable do |da|
      create :driver_compliance, driver: (da.document.try(:documentable) || create(:driver))
    end
  end
end

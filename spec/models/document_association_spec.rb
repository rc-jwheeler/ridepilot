require 'rails_helper'

RSpec.describe DocumentAssociation, type: :model do
  it "requires a document" do
    association = build :document_association, document: nil
    expect(association.valid?).to be_falsey
    expect(association.errors.keys).to include :document
  end

  it "requires an associable object" do
    association = build :document_association, associable: nil
    expect(association.valid?).to be_falsey
    expect(association.errors.keys).to include :associable
  end
  
  it "requires that the document and associable share the same parent object" do
    document = create :document
    associable = create :driver_compliance
    association = build :document_association, document: document, associable: associable
    expect(association.valid?).to be_falsey
    expect(association.errors.keys).to include :base
    
    association.associable.update_attribute :driver, document.documentable
    expect(association.valid?).to be_truthy
  end
  
  it "calls associable#to_s on #to_s" do
    association = create :document_association
    expect(association.associable).to receive(:to_s).and_return("Foo")
    expect(association.to_s).to eq "Foo"
  end
end

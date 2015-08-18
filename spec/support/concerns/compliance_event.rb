require 'spec_helper'

# For model specs
RSpec.shared_examples "a compliance event" do
  before do
    @described_class_factory = described_class.name.underscore.to_sym
  end
  
  it "requires an event name" do
    compliance = build @described_class_factory, event: nil
    expect(compliance.valid?).to be_falsey
    expect(compliance.errors.keys).to include :event
  end

  it "requires compliance date to be on or before today, when specified" do
    compliance = build @described_class_factory, compliance_date: nil
    expect(compliance.valid?).to be_truthy

    compliance.compliance_date = Date.current.tomorrow
    expect(compliance.valid?).to be_falsey
    expect(compliance.errors.keys).to include :compliance_date

    compliance.compliance_date = Date.current
    expect(compliance.valid?).to be_truthy
  end

  describe "#complete!" do
    it "instantly sets the compliance date to the current date" do
      compliance = create @described_class_factory
      expect(compliance.compliance_date).to be_nil
      compliance.complete!
      expect(compliance.reload.compliance_date).to eql Date.current
    end
  end

  describe "#complete?" do
    it "knows if the record is considered complete" do
      compliance = create @described_class_factory
      expect(compliance.complete?).to be_falsey
      compliance.complete!
      expect(compliance.reload.complete?).to be_truthy
    end
  end

  describe ".incomplete" do
    it "finds compliance events that do not have a compliance date" do
      compliance_1 = create @described_class_factory, compliance_date: nil
      compliance_2 = create @described_class_factory, compliance_date: ""
      compliance_3 = create @described_class_factory, compliance_date: Date.current

      incomplete = described_class.incomplete
      expect(incomplete).to include compliance_1, compliance_2
      expect(incomplete).not_to include compliance_3
    end
  end
end

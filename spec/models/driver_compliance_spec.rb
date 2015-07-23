require 'rails_helper'

RSpec.describe DriverCompliance, type: :model do
  it "requires a driver" do
    compliance = build :driver_compliance, driver: nil
    expect(compliance.valid?).to be_falsey
    expect(compliance.errors.keys).to include :driver
  end

  it "requires an event" do
    compliance = build :driver_compliance, event: nil
    expect(compliance.valid?).to be_falsey
    expect(compliance.errors.keys).to include :event
  end

  it "requires a due date" do
    compliance = build :driver_compliance, due_date: nil
    expect(compliance.valid?).to be_falsey
    expect(compliance.errors.keys).to include :due_date
  end

  it "requires an event date on or after the due date" do
    compliance = build :driver_compliance, due_date: Date.current, compliance_date: Date.current.yesterday
    expect(compliance.valid?).to be_falsey
    expect(compliance.errors.keys).to include :compliance_date

    compliance.compliance_date = Date.current
    expect(compliance.valid?).to be_truthy
  end

  it "requires an event date on or before today" do
    compliance = build :driver_compliance, due_date: Date.current, compliance_date: Date.current.tomorrow
    expect(compliance.valid?).to be_falsey
    expect(compliance.errors.keys).to include :compliance_date

    compliance.compliance_date = Date.current
    expect(compliance.valid?).to be_truthy
  end
end

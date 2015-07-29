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

  it "requires an compliance date on or before today" do
    compliance = build :driver_compliance, due_date: Date.current, compliance_date: Date.current.tomorrow
    expect(compliance.valid?).to be_falsey
    expect(compliance.errors.keys).to include :compliance_date

    compliance.compliance_date = Date.current
    expect(compliance.valid?).to be_truthy
  end
  
  describe "#complete!" do
    it "instantly sets the compliance date to the current date" do
      compliance = create :driver_compliance
      expect(compliance.compliance_date).to be_nil
      compliance.complete!
      expect(compliance.reload.compliance_date).to eql Date.current
    end
  end
  
  describe ".for" do
    it "finds compliance events for a specified driver ID" do
      driver_1 = create :driver
      for_driver_1 = create :driver_compliance, driver: driver_1
      for_driver_2 = create :driver_compliance
      expect(DriverCompliance.for(driver_1.id)).to include for_driver_1
      expect(DriverCompliance.for(driver_1.id)).not_to include for_driver_2
    end
  end
  
  describe ".overdue" do
    it "finds compliance events overdue as of today by default" do
      compliance = create :driver_compliance, due_date: Date.current.yesterday
      expect(DriverCompliance.overdue).to include compliance
    end
  
    it "can find overdue compliance events as of a specific date" do
      compliance = create :driver_compliance, due_date: Date.current
      expect(DriverCompliance.overdue(as_of: Date.current.tomorrow)).to include compliance
    end
  end
  
  describe ".due_soon" do
    before do
      @compliance_today = create :driver_compliance, due_date: Date.current
      @compliance_tomorrow = create :driver_compliance, due_date: Date.current.tomorrow
      @compliance_later = create :driver_compliance, due_date: Date.current + 7.days
    end

    it "finds items due as of today through the next 6 days by default" do
      compliances = DriverCompliance.due_soon
      expect(compliances).to include @compliance_today, @compliance_tomorrow
      expect(compliances).to_not include @compliance_later
    end
    
    it "can find items due as of a specific date" do
      compliances = DriverCompliance.due_soon(as_of: Date.current.tomorrow)
      expect(compliances).to_not include @compliance_today
      expect(compliances).to include @compliance_tomorrow, @compliance_later
    end
    
    it "can find items due through a specific date" do
      compliances = DriverCompliance.due_soon(through: Date.current + 7.days)
      expect(compliances).to include @compliance_today, @compliance_tomorrow, @compliance_later
    end
  end
end

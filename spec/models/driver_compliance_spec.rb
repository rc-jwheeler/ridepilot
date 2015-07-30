require 'rails_helper'

RSpec.describe DriverCompliance, type: :model do
  it "requires a driver" do
    compliance = build :driver_compliance, driver: nil
    expect(compliance.valid?).to be_falsey
    expect(compliance.errors.keys).to include :driver
  end

  it "requires an event name" do
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
  
  describe "recurring events" do
    it "does not allow modifying anything other than compliance date" do
      compliance = create :driver_compliance, :recurring, event: "My Event", compliance_date: nil
      compliance.event = "My New Event"
      expect(compliance.valid?).to be_falsey
      expect(compliance.errors.keys).to include :event

      compliance.reload
      compliance.compliance_date = Date.current
      expect(compliance.valid?).to be_truthy
    end
  
    it "does not allow destruction of the record" do
      compliance = create :driver_compliance, :recurring
      expect {
        compliance.destroy
      }.not_to change(DriverCompliance, :count)
      expect(compliance.errors).not_to be_empty

      compliance.valid? # Clear errors array, reload alone is not sufficient
      compliance.update_attribute :recurring_driver_compliance, nil
      expect {
        compliance.destroy
      }.to change(DriverCompliance, :count).by(-1)
    end
  end
  
  describe ".incomplete" do
    it "finds compliance events that do not have a compliance date" do
      compliance_1 = create :driver_compliance, compliance_date: nil
      compliance_2 = create :driver_compliance, compliance_date: ""
      compliance_3 = create :driver_compliance, compliance_date: Date.current
      expect(DriverCompliance.incomplete).to include compliance_1
      expect(DriverCompliance.incomplete).to include compliance_2
      expect(DriverCompliance.incomplete).not_to include compliance_3
    end
  end
  
  describe ".for" do
    before do
      @driver_1 = create :driver
      @driver_2 = create :driver
      @for_driver_1 = create :driver_compliance, driver: @driver_1
      @for_driver_2 = create :driver_compliance, driver: @driver_2
    end
    
    it "finds compliance events for a specified driver ID" do
      expect(DriverCompliance.for(@driver_1.id)).to include @for_driver_1
      expect(DriverCompliance.for(@driver_1.id)).not_to include @for_driver_2
    end

    it "can find compliance events for an array of driver IDs" do
      expect(DriverCompliance.for([@driver_1.id, @driver_2.id])).to include @for_driver_1
      expect(DriverCompliance.for([@driver_1.id, @driver_2.id])).to include @for_driver_2
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

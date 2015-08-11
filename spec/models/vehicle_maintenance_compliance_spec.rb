require 'rails_helper'

RSpec.describe VehicleMaintenanceCompliance, type: :model do
  it "requires a vehicle" do
    compliance = build :vehicle_maintenance_compliance, vehicle: nil
    expect(compliance.valid?).to be_falsey
    expect(compliance.errors.keys).to include :vehicle
  end

  it "requires an event name" do
    compliance = build :vehicle_maintenance_compliance, event: nil
    expect(compliance.valid?).to be_falsey
    expect(compliance.errors.keys).to include :event
  end
  
  it "requires a due_type of either 'date', 'mileage', or 'both'" do
    compliance = build :vehicle_maintenance_compliance, due_type: nil, due_date: Date.current, due_mileage: 1
    expect(compliance.valid?).to be_falsey
    expect(compliance.errors.keys).to include :due_type

    compliance.due_type = "foo"
    expect(compliance.valid?).to be_falsey
    expect(compliance.errors.keys).to include :due_type

    %w(date mileage both).each do |due_type|
      compliance.due_type = due_type
      expect(compliance.valid?).to be_truthy
    end
  end

  describe "due_types" do
    describe "date" do
      before do
        @compliance = build :vehicle_maintenance_compliance, due_type: "date", due_date: Date.current, due_mileage: 1
      end
      
      it "requires a due_date on or after today" do
        @compliance.due_date = nil
        expect(@compliance.valid?).to be_falsey
        expect(@compliance.errors.keys).to include :due_date

        @compliance.due_date = Date.current.yesterday
        expect(@compliance.valid?).to be_falsey
        expect(@compliance.errors.keys).to include :due_date

        @compliance.due_date = Date.current
        expect(@compliance.valid?).to be_truthy
      end
      
      it "does not require a due_mileage" do
        @compliance.due_mileage = nil
        expect(@compliance.valid?).to be_truthy
      end
    end

    describe "mileage" do
      before do
        @compliance = build :vehicle_maintenance_compliance, due_type: "mileage", due_date: Date.current, due_mileage: 1
      end

      it "does not require a due_date" do
        @compliance.due_date = nil
        expect(@compliance.valid?).to be_truthy
      end
      
      it "requires due_mileage to be an integer > 0" do
        @compliance.due_mileage = nil
        expect(@compliance.valid?).to be_falsey
        expect(@compliance.errors.keys).to include :due_mileage

        @compliance.due_mileage = 0
        expect(@compliance.valid?).to be_falsey
        expect(@compliance.errors.keys).to include :due_mileage

        @compliance.due_mileage = 1.2
        expect(@compliance.valid?).to be_falsey
        expect(@compliance.errors.keys).to include :due_mileage

        @compliance.due_mileage = 1
        expect(@compliance.valid?).to be_truthy
      end
    end

    describe "both" do
      before do
        @compliance = build :vehicle_maintenance_compliance, due_type: "both", due_date: Date.current, due_mileage: 1
      end
      
      it "requires a due_date on or after today" do
        @compliance.due_date = nil
        expect(@compliance.valid?).to be_falsey
        expect(@compliance.errors.keys).to include :due_date

        @compliance.due_date = Date.current.yesterday
        expect(@compliance.valid?).to be_falsey
        expect(@compliance.errors.keys).to include :due_date

        @compliance.due_date = Date.current
        expect(@compliance.valid?).to be_truthy
      end

      it "requires due_mileage to be an integer > 0" do
        @compliance.due_mileage = nil
        expect(@compliance.valid?).to be_falsey
        expect(@compliance.errors.keys).to include :due_mileage

        @compliance.due_mileage = 0
        expect(@compliance.valid?).to be_falsey
        expect(@compliance.errors.keys).to include :due_mileage

        @compliance.due_mileage = 1.2
        expect(@compliance.valid?).to be_falsey
        expect(@compliance.errors.keys).to include :due_mileage

        @compliance.due_mileage = 1
        expect(@compliance.valid?).to be_truthy
      end
    end
  end

  it "requires compliance date to be on or before today, when specified" do
    compliance = build :vehicle_maintenance_compliance, compliance_date: nil
    expect(compliance.valid?).to be_truthy

    compliance.compliance_date = Date.current.tomorrow
    expect(compliance.valid?).to be_falsey
    expect(compliance.errors.keys).to include :compliance_date

    compliance.compliance_date = Date.current
    expect(compliance.valid?).to be_truthy
  end
  
  describe "#complete!" do
    it "instantly sets the compliance date to the current date" do
      compliance = create :vehicle_maintenance_compliance
      expect(compliance.compliance_date).to be_nil
      compliance.complete!
      expect(compliance.reload.compliance_date).to eql Date.current
    end
  end

  describe "#complete?" do
    it "knows if the record is considered complete" do
      compliance = create :vehicle_maintenance_compliance
      expect(compliance.complete?).to be_falsey
      compliance.complete!
      expect(compliance.reload.complete?).to be_truthy
    end
  end

  describe ".complete" do
    it "finds compliance events that have a compliance date" do
      compliance_1 = create :vehicle_maintenance_compliance, compliance_date: nil
      compliance_2 = create :vehicle_maintenance_compliance, compliance_date: ""
      compliance_3 = create :vehicle_maintenance_compliance, compliance_date: Date.current
      expect(VehicleMaintenanceCompliance.complete).not_to include compliance_1
      expect(VehicleMaintenanceCompliance.complete).not_to include compliance_2
      expect(VehicleMaintenanceCompliance.complete).to include compliance_3
    end
  end
  
  describe ".incomplete" do
    it "finds compliance events that do not have a compliance date" do
      compliance_1 = create :vehicle_maintenance_compliance, compliance_date: nil
      compliance_2 = create :vehicle_maintenance_compliance, compliance_date: ""
      compliance_3 = create :vehicle_maintenance_compliance, compliance_date: Date.current
      expect(VehicleMaintenanceCompliance.incomplete).to include compliance_1
      expect(VehicleMaintenanceCompliance.incomplete).to include compliance_2
      expect(VehicleMaintenanceCompliance.incomplete).not_to include compliance_3
    end
  end
  
  describe ".for" do
    before do
      @vehicle_1 = create :vehicle
      @vehicle_2 = create :vehicle
      @for_vehicle_1 = create :vehicle_maintenance_compliance, vehicle: @vehicle_1
      @for_vehicle_2 = create :vehicle_maintenance_compliance, vehicle: @vehicle_2
    end
    
    it "finds compliance events for a specified vehicle or vehicle_id" do
      expect(VehicleMaintenanceCompliance.for(@vehicle_1)).to include @for_vehicle_1
      expect(VehicleMaintenanceCompliance.for(@vehicle_1)).not_to include @for_vehicle_2
    end

    it "can find compliance events for an array of vehicles or vehicle_ids" do
      expect(VehicleMaintenanceCompliance.for([@vehicle_1, @vehicle_2])).to include @for_vehicle_1
      expect(VehicleMaintenanceCompliance.for([@vehicle_1, @vehicle_2])).to include @for_vehicle_2
    end
  end
  
  describe ".overdue" do
    it "finds compliance events overdue as of today by default" do
      pending
      compliance = create :vehicle_maintenance_compliance, due_date: Date.current.yesterday
      expect(VehicleMaintenanceCompliance.overdue).to include compliance
    end
  
    it "can find overdue compliance events as of a specific date" do
      pending
      compliance = create :vehicle_maintenance_compliance, due_date: Date.current
      expect(VehicleMaintenanceCompliance.overdue(as_of: Date.current.tomorrow)).to include compliance
    end
  end
  
  describe ".due_soon" do
    before do
      @compliance_today = create :vehicle_maintenance_compliance, due_date: Date.current
      @compliance_tomorrow = create :vehicle_maintenance_compliance, due_date: Date.current.tomorrow
      @compliance_later = create :vehicle_maintenance_compliance, due_date: Date.current + 7.days
    end

    skip "finds items due as of today through the next 6 days by default" do
      pending
      compliances = VehicleMaintenanceCompliance.due_soon
      expect(compliances).to include @compliance_today, @compliance_tomorrow
      expect(compliances).to_not include @compliance_later
    end
    
    skip "can find items due as of a specific date" do
      pending
      compliances = VehicleMaintenanceCompliance.due_soon(as_of: Date.current.tomorrow)
      expect(compliances).to_not include @compliance_today
      expect(compliances).to include @compliance_tomorrow, @compliance_later
    end
    
    skip "can find items due through a specific date" do
      pending
      compliances = VehicleMaintenanceCompliance.due_soon(through: Date.current + 7.days)
      expect(compliances).to include @compliance_today, @compliance_tomorrow, @compliance_later
    end
  end
  
  it "knows its vehicle's last odometer reading" do
    compliance = create :vehicle_maintenance_compliance
    expect(compliance.vehicle).to receive(:last_odometer_reading).and_return(123)
    expect(compliance.vehicle_odometer_reading).to eq 123
  end    
end

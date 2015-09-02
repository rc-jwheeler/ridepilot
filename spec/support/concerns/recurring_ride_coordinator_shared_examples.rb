require 'spec_helper'

# For model specs
RSpec.shared_examples "a recurring ride coordinator" do
  before do
    @described_class_factory = described_class.name.underscore.to_sym
  end

  describe "DAYS_OF_WEEK" do
    it "contains a list of the days of the week" do
      expect(described_class::DAYS_OF_WEEK).to include "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"
    end
    
    it "defines a method that checks whether it repeats for each given day of the week" do
      coordinator = build @described_class_factory
      expect(coordinator).to respond_to :repeats_sundays
      expect(coordinator).to respond_to :repeats_sundays=
      expect(coordinator).to respond_to :repeats_mondays
      expect(coordinator).to respond_to :repeats_mondays=
      expect(coordinator).to respond_to :repeats_tuesdays
      expect(coordinator).to respond_to :repeats_tuesdays=
      expect(coordinator).to respond_to :repeats_wednesdays
      expect(coordinator).to respond_to :repeats_wednesdays=
      expect(coordinator).to respond_to :repeats_thursdays
      expect(coordinator).to respond_to :repeats_thursdays=
      expect(coordinator).to respond_to :repeats_fridays
      expect(coordinator).to respond_to :repeats_fridays=
      expect(coordinator).to respond_to :repeats_saturdays
      expect(coordinator).to respond_to :repeats_saturdays=
    end
  end
  
  describe "#repetition_driver_id=" do
    before do
      @coordinator = build @described_class_factory
    end
    
    it "sets the @repetition_driver_id instance variable" do
      expect(@coordinator.instance_variable_get("@repetition_driver_id")).to be_nil
      @coordinator.repetition_driver_id = 5
      expect(@coordinator.instance_variable_get("@repetition_driver_id")).to eq 5
    end
    
    it "converts blank values ('') to nil" do
      @coordinator.repetition_driver_id = ""
      expect(@coordinator.instance_variable_get("@repetition_driver_id")).to be_nil
    end
    
    it "converts non-blank values to integers" do
      @coordinator.repetition_driver_id = "5"
      expect(@coordinator.instance_variable_get("@repetition_driver_id")).to eq 5
    end
  end

  describe "#repetition_driver_id" do
    before do
      @coordinator = build @described_class_factory
    end
    
    it "returns the @repetition_driver_id instance variable if it's present" do
      @coordinator.instance_variable_set "@repetition_driver_id", 5
      expect(@coordinator.repetition_driver_id).to eq 5
    end

    # TODO make repeating_trip including-class agnostic
    it "returns the repeating_trip.driver_id if @repetition_driver_id is nil and the repeating_trip is present" do
      driver = create :driver
      @coordinator.repeating_trip = create :repeating_trip, driver: driver
      expect(@coordinator.repetition_driver_id).to eq driver.id
    end

    # TODO make repeating_trip including-class agnostic
    it "sets the @repetition_driver_id instance variable if it is nil and the repeating_trip is present" do
      driver = create :driver
      @coordinator.repeating_trip = create :repeating_trip, driver: driver
      expect(@coordinator.repetition_driver_id).to eq driver.id
      expect(@coordinator.instance_variable_get("@repetition_driver_id")).to eq driver.id
    end
  end

  describe "#repetition_vehicle_id=" do
    before do
      @coordinator = build @described_class_factory
    end
    
    it "sets the @repetition_vehicle_id instance variable" do
      expect(@coordinator.instance_variable_get("@repetition_vehicle_id")).to be_nil
      @coordinator.repetition_vehicle_id = 5
      expect(@coordinator.instance_variable_get("@repetition_vehicle_id")).to eq 5
    end
    
    it "converts blank values ('') to nil" do
      @coordinator.repetition_vehicle_id = ""
      expect(@coordinator.instance_variable_get("@repetition_vehicle_id")).to be_nil
    end

    it "converts non-blank values to integers" do
      @coordinator.repetition_vehicle_id = "5"
      expect(@coordinator.instance_variable_get("@repetition_vehicle_id")).to eq 5
    end
  end

  describe "#repetition_vehicle_id" do
    before do
      @coordinator = build @described_class_factory
    end
    
    it "returns the @repetition_vehicle_id instance variable if it's present" do
      @coordinator.instance_variable_set "@repetition_vehicle_id", 5
      expect(@coordinator.repetition_vehicle_id).to eq 5
    end
    
    # TODO make repeating_trip including-class agnostic
    it "returns the repeating_trip.vehicle_id if @repetition_vehicle_id is nil and the repeating_trip is present" do
      vehicle = create :vehicle
      @coordinator.repeating_trip = create :repeating_trip, vehicle: vehicle
      expect(@coordinator.repetition_vehicle_id).to eq vehicle.id
    end

    # TODO make repeating_trip including-class agnostic
    it "sets the @repetition_vehicle_id instance variable if it is nil and the repeating_trip is present" do
      vehicle = create :vehicle
      @coordinator.repeating_trip = create :repeating_trip, vehicle: vehicle
      expect(@coordinator.repetition_vehicle_id).to eq vehicle.id
      expect(@coordinator.instance_variable_get("@repetition_vehicle_id")).to eq vehicle.id
    end
  end

  describe "#repetition_customer_informed=" do
    before do
      @coordinator = build @described_class_factory
    end

    it "sets the @repetition_customer_informed instance variable" do
      expect(@coordinator.instance_variable_get("@repetition_customer_informed")).to be_nil
      @coordinator.repetition_customer_informed = true
      expect(@coordinator.instance_variable_get("@repetition_customer_informed")).to eq true
    end

    it "converts '1' and truthy values to true" do
      @coordinator.repetition_customer_informed = "1"
      expect(@coordinator.instance_variable_get("@repetition_customer_informed")).to eq true

      @coordinator.repetition_customer_informed = true
      expect(@coordinator.instance_variable_get("@repetition_customer_informed")).to eq true
    end
    
    it "converts other values to false" do
      @coordinator.repetition_customer_informed = "0"
      expect(@coordinator.instance_variable_get("@repetition_customer_informed")).to eq false

      @coordinator.repetition_customer_informed = "false"
      expect(@coordinator.instance_variable_get("@repetition_customer_informed")).to eq false

      @coordinator.repetition_customer_informed = false
      expect(@coordinator.instance_variable_get("@repetition_customer_informed")).to eq false
    end
  end

  describe "#repetition_customer_informed" do
    before do
      @coordinator = build @described_class_factory
    end

    it "returns the @repetition_customer_informed instance variable if it's present" do
      @coordinator.instance_variable_set "@repetition_customer_informed", true
      expect(@coordinator.repetition_customer_informed).to eq true
    end
    
    # TODO make repeating_trip including-class agnostic
    it "returns the repeating_trip.customer_informed if @repetition_customer_informed is nil and the repeating_trip is present" do
      @coordinator.repeating_trip = create :repeating_trip, customer_informed: true
      expect(@coordinator.repetition_customer_informed).to eq true
    end

    # TODO make repeating_trip including-class agnostic
    it "sets the @repetition_customer_informed instance variable if it is nil and the repeating_trip is present" do
      @coordinator.repeating_trip = create :repeating_trip, customer_informed: true
      expect(@coordinator.repetition_customer_informed).to eq true
      expect(@coordinator.instance_variable_get("@repetition_customer_informed")).to eq true
    end
  end

  describe "#repetition_interval=" do
    before do
      @coordinator = build @described_class_factory
    end

    it "sets the @repetition_interval instance variable" do
      expect(@coordinator.instance_variable_get("@repetition_interval")).to be_nil
      @coordinator.repetition_interval = 5
      expect(@coordinator.instance_variable_get("@repetition_interval")).to eq 5
    end

    it "converts values to integers" do
      @coordinator.repetition_interval = "5"
      expect(@coordinator.instance_variable_get("@repetition_interval")).to eq 5
    end
  end

  describe "#repetition_interval" do
    before do
      @coordinator = build @described_class_factory
    end

    it "returns the @repetition_interval instance variable if it's present" do
      @coordinator.instance_variable_set "@repetition_interval", 5
      expect(@coordinator.repetition_interval).to eq 5
    end
    
    # TODO make repeating_trip including-class agnostic
    it "returns the repeating_trip.schedule_attributes.interval if @repetition_interval is nil and the repeating_trip is present" do
      @coordinator.repeating_trip = create :repeating_trip, schedule_attributes: {repeat: 1, interval: 5, interval_unit: "day"}
      expect(@coordinator.repetition_interval).to eq 5
    end
    
    # TODO make repeating_trip including-class agnostic
    it "sets the @repetition_interval instance variable if it is nil and the repeating_trip is present" do
      @coordinator.repeating_trip = create :repeating_trip, schedule_attributes: {repeat: 1, interval: 5, interval_unit: "day"}
      expect(@coordinator.repetition_interval).to eq 5
      expect(@coordinator.instance_variable_get("@repetition_interval")).to eq 5
    end

    # TODO make repeating_trip including-class agnostic
    it "returns 1 if @repetition_interval is nil and the repeating_trip is not present" do
      expect(@coordinator.instance_variable_get("@repetition_interval")).to be_nil
      expect(@coordinator.repeating_trip).to be_nil
      expect(@coordinator.repetition_interval).to eq 1
    end
  end

  describe "#is_repeating_trip?" do
    before do
      @coordinator = build @described_class_factory
    end
    
    it "is true if repetition_interval is greater than 0 and at least one of the repeats_x methods returns true" do
      allow(@coordinator).to receive(:repetition_interval).and_return(1)
      allow(@coordinator).to receive(:repeats_sundays).and_return(true)
      expect(@coordinator.is_repeating_trip?).to be_truthy
    end

    it "is false if repetition_interval <= 0, even if one of the repeats_x methods returns true" do
      allow(@coordinator).to receive(:repeats_sundays).and_return(true)
      @coordinator.repetition_interval = 0
      expect(@coordinator.is_repeating_trip?).to be_falsey
      @coordinator.repetition_interval = 1
      expect(@coordinator.is_repeating_trip?).to be_truthy
    end
    
    it "is false if none of the repeats_x methods return true, even if repetition_interval > 0" do
      allow(@coordinator).to receive(:repetition_interval).and_return(1)
      expect(@coordinator.is_repeating_trip?).to be_falsey
      @coordinator.repeats_sundays = true
      expect(@coordinator.is_repeating_trip?).to be_truthy
    end
  end    
end

require "rails_helper"

RSpec.describe RepeatingTrip do
  it_behaves_like "a recurring ride coordinator scheduler"
    
  describe "#instantiate!" do
    # TODO Add some robust examples
    # Partially exercised by recurring_ride_coordinator_shared_examples.rb
    it "generates runs"
  end

  it_behaves_like "a recurring ride coordinator" do
    before do
      @scheduled_instance_class = Trip 

      # To help us know what attribute to check occurrence dates against
      @occurrence_date_attribute = :pickup_time
    end
  end

  describe "service_level" do
    it "should be an integer field" do
      t = RepeatingTrip.new
      expect(t).to respond_to(:service_level_id)
      t.service_level_id = "1"
      expect(t.service_level_id).to eq(1)
      t.service_level_id = "0"
      expect(t.service_level_id).to eq(0)
    end
  end

  describe "medicaid_eligible" do
    it "should be a boolean field" do
      t = RepeatingTrip.new
      expect(t).to respond_to(:medicaid_eligible)
      t.medicaid_eligible = "1"
      expect(t.medicaid_eligible).to be_truthy
      t.medicaid_eligible = "0"
      expect(t.medicaid_eligible).to be_falsey
    end
  end
  
  describe "#trip_size" do
    before do
      @trip = build :repeating_trip
    end
    
    it "assumes a minimum size of 1" do
      expect(@trip.trip_size).to eq 1
    end

    it "accounts for guests and attendants" do
      @trip.guest_count = 1
      @trip.attendant_count = 1
      expect(@trip.trip_size).to eq 3
    end

    it "accounts for groups" do
      @trip.customer = create :customer, group: true
      @trip.group_size = 4
      expect(@trip.trip_size).to eq 4
    end
  end

  describe ".during" do
    before do
      @start_time = Time.zone.parse("14:30")
      @end_time   = Time.zone.parse("15:30")
      
      @starts_and_ends_before_start        = create :repeating_trip, pickup_time: @start_time - 15.minutes, appointment_time: @start_time
      @starts_before_start_ends_before_end = create :repeating_trip, pickup_time: @start_time - 15.minutes, appointment_time: @end_time
      @starts_after_start_ends_after_end   = create :repeating_trip, pickup_time: @start_time,              appointment_time: @end_time + 15.minutes
      @starts_after_start_ends_before_end  = create :repeating_trip, pickup_time: @start_time,              appointment_time: @end_time
      @starts_and_ends_after_end           = create :repeating_trip, pickup_time: @end_time,                appointment_time: @end_time + 15.minutes
      @starts_before_start_ends_after_end  = create :repeating_trip, pickup_time: @start_time - 15.minutes, appointment_time: @end_time + 15.minutes
      
      @during = RepeatingTrip.during(@start_time, @end_time)
    end
    
    it "returns trips that are occurring in the same time frame" do
      expect(@during).to include @starts_before_start_ends_before_end, 
                                 @starts_after_start_ends_after_end, 
                                 @starts_after_start_ends_before_end, 
                                 @starts_before_start_ends_after_end
    end

    it "ignores trips that start and end before the time frame" do
      expect(@during).not_to include @starts_and_ends_before_start
    end
    
    it "ignores trips that start and end after the time frame" do
      expect(@during).not_to include @starts_and_ends_after_end
    end
  end
  
  describe ".by_funding_source" do
    before do
      @funding_source_1 = create :funding_source, name: "Foo"
      @funding_source_2 = create :funding_source, name: "Bar"
      
      @trip_1 = create :repeating_trip, funding_source: @funding_source_1
      @trip_2 = create :repeating_trip, funding_source: @funding_source_2
    end
    
    it "finds trips by funding source by name" do
      expect(RepeatingTrip.by_funding_source("Foo")).to include @trip_1
      expect(RepeatingTrip.by_funding_source("Foo")).not_to include @trip_2
      expect(RepeatingTrip.by_funding_source("Bar")).to include @trip_2
      expect(RepeatingTrip.by_funding_source("Bar")).not_to include @trip_1
    end
  end
  
  describe ".by_trip_purpose" do
    before do
      @trip_purpose_1 = create :trip_purpose, name: "Foo"
      @trip_purpose_2 = create :trip_purpose, name: "Bar"
      
      @trip_1 = create :repeating_trip, trip_purpose: @trip_purpose_1
      @trip_2 = create :repeating_trip, trip_purpose: @trip_purpose_2
    end
    
    it "finds trips by trip purpose by name" do
      expect(RepeatingTrip.by_trip_purpose("Foo")).to include @trip_1
      expect(RepeatingTrip.by_trip_purpose("Foo")).not_to include @trip_2
      expect(RepeatingTrip.by_trip_purpose("Bar")).to include @trip_2
      expect(RepeatingTrip.by_trip_purpose("Bar")).not_to include @trip_1
    end
  end
end

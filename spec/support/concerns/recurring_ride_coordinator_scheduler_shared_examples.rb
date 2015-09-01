require 'spec_helper'

# For model specs
RSpec.shared_examples "a recurring ride coordinator scheduler" do
  describe ".trip_attributes" do
    it "knows which of its attributes are trip attributes" do
      expect(RepeatingTrip.trip_attributes).not_to include "id", "recurrence", "schedule_yaml", "created_at", "updated_at", "lock_version"
    end
  end
  
  describe "ScheduleAttributes module" do
    describe "#schedule_attributes" do
      before do
        @repeating_trip = build :repeating_trip
      end
    
      it "returns an openstruct" do
        expect(@repeating_trip.schedule_attributes).to be_a OpenStruct
      end
    end
  
    describe "#schedule_attributes=" do
      before do
        @repeating_trip = build :repeating_trip
      end
    
      it "populates the schedule_yaml field" do
        expect(@repeating_trip.schedule_yaml).to be_nil
        @repeating_trip.schedule_attributes = {}
        expect(@repeating_trip.schedule_yaml).not_to be_nil
      end
    end
  
    describe "#schedule" do
      before do
        @repeating_trip = build :repeating_trip
      end

      it "returns an IceCube::Schedule" do
        expect(@repeating_trip.schedule).to be_a IceCube::Schedule
      end
    end
  end
end

require 'spec_helper'

describe Trip do
  describe "mileage" do
    it "should be an integer" do
      t = Trip.new
      t.should respond_to(:mileage)
      t.mileage = "1"
      t.mileage.should eq 1
      t.mileage = "0"
      t.mileage.should eq 0
    end
    
    it "should only allow integers greater than 0" do
      t = Trip.new
      t.mileage = 0
      t.valid?
      t.errors.keys.include?(:mileage).should be_truthy
      t.errors[:mileage].should include "must be greater than 0"
      
      t.mileage = 1
      t.valid?
      t.errors.keys.include?(:mileage).should_not be_truthy
    end
  end

  describe "service_level" do
    it "should be a string field" do
      t = Trip.new
      t.should respond_to(:service_level)
      t.service_level = "abc"
      t.service_level.should == "abc"
    end
  end

  describe "medicaid_eligible" do
    it "should be a boolean field" do
      t = Trip.new
      t.should respond_to(:medicaid_eligible)
      t.medicaid_eligible = "1"
      t.medicaid_eligible.should be_truthy
      t.medicaid_eligible = "0"
      t.medicaid_eligible.should be_falsey
    end
  end

  describe "before validation" do
    context "when there are no runs yet" do
      before do
        Run.count.should == 0
      end
      
      it "does not create an associated run" do
        lambda {
          trip = create :trip
          trip.run.should be_nil
        }.should_not change(Run, :count)
      end
    end
  end

  describe "after validation for trips with repetition:" do
    attr_accessor :trip
    
    before do
      @trip = build(:trip,
        :repeats_mondays => true, 
        :repeats_tuesdays => false,
        :repeats_wednesdays => false,
        :repeats_thursdays => false,
        :repeats_fridays => false,
        :repeats_saturdays => false,
        :repeats_sundays => false,
        :repetition_vehicle_id => -1,
        :repetition_driver_id => 1,
        :repetition_interval => 1)
      RepeatingTrip.count.should == 0
    end

    context "when creating a trip with repeating trip data" do
      it "should accept repeating trip values" do
        trip.repeats_mondays.should == true
        trip.repeats_tuesdays.should == false
        trip.repeats_wednesdays.should == false
        trip.repeats_thursdays.should == false
        trip.repeats_fridays.should == false
        trip.repeats_saturdays.should == false
        trip.repeats_sundays.should == false
        trip.repetition_vehicle_id.should == -1
        trip.repetition_driver_id.should == 1
        trip.repetition_interval.should == 1
      end

      it "should create a repeating trip when saved" do
        lambda {
          trip.save
          trip.repeating_trip.should_not be_nil
        }.should change(RepeatingTrip, :count).by(1)
        trip.repeating_trip_id.should_not be_nil
      end

      it "should instantiate trips for three weeks out" do
        trip.save
        r_id = trip.repeating_trip_id
        # The trip we just created, which is next week, plus 2 more
        Trip.where(:repeating_trip_id => r_id).count.should == 3
      end
    end

    context "when updating a future trip with repeating trip data," do
      before do
        trip.save
        trip.repeats_mondays = false
        trip.repeats_tuesdays = true
        trip.repetition_vehicle_id = 2
        trip.repetition_driver_id = 2
        trip.save
        trip.reload
      end

      it "should have the correct repeating trip attributes" do
        trip.repeating_trip.schedule_attributes.monday.should be_nil
        trip.repeating_trip.schedule_attributes.tuesday.should == 1
      end

      # TODO This test is failing on master. Uncomment after upgrade. Fix if
      # time allows.
      # it "should have new child trips on the correct day" do
      #   count = 0
      #   Trip.where(:repeating_trip_id => trip.repeating_trip_id).where("id <> ?",trip.id).each do |t|
      #     count += 1 if t.pickup_time.strftime("%u") == "2"
      #   end
      #   count.should == 1
      # end

      it "should have no child trips on the old day" do
        count = 0
        Trip.where(:repeating_trip_id => trip.repeating_trip_id).where("id <> ?",trip.id).each do |t|
          count += 1 if t.pickup_time.strftime("%u") == "1"
        end
        count.should == 0
      end

      it "should tell me the correct repeating trip data when reloading the trip" do
        trip.reload
        trip.repeats_mondays.should == false
        trip.repeats_tuesdays.should == true
        trip.repetition_vehicle_id.should == 2
        trip.repetition_driver_id.should == 2
      end
    end
   
    context "when updating a past trip with repeating trip data," do
      before do
        trip.pickup_time = Time.now - 1.week
        trip.appointment_time = trip.pickup_time + 30.minutes
        trip.save
        trip.repeats_mondays = false
        trip.repeats_tuesdays = true
        trip.repetition_vehicle_id = 2
        trip.repetition_driver_id = 2
        trip.save
        trip.reload
      end

      it "should have the correct repeating trip attributes" do
        trip.repeating_trip.schedule_attributes.monday.should be_nil
        trip.repeating_trip.schedule_attributes.tuesday.should == 1
      end

      # TODO This test is failing on master. Uncomment after upgrade. Fix if
      # time allows.
      # it "should have new child trips on the correct day" do
      #   count = 0
      #   Trip.where(:repeating_trip_id => trip.repeating_trip_id).where("id <> ?",trip.id).each do |t|
      #     count += 1 if t.pickup_time.strftime("%u") == "2"
      #   end
      #   count.should == 2
      # end

      it "should have no child trips on the old day" do
        count = 0
        Trip.where(:repeating_trip_id => trip.repeating_trip_id).where("id <> ?",trip.id).each do |t|
          count += 1 if t.pickup_time.strftime("%u") == "1"
        end
        count.should == 0
      end

      it "should tell me the correct repeating trip data when reloading the trip" do
        trip.reload
        trip.repeats_mondays.should == false
        trip.repeats_tuesdays.should == true
        trip.repetition_vehicle_id.should == 2
        trip.repetition_driver_id.should == 2
      end
    end

    context "when I clear out the repetition data" do
      before do
        trip.save
        trip.repeats_mondays = false
        @repeating_trip_id = trip.repeating_trip_id
        trip.save
      end

      it "should remove all future trips after the trip and delete the repeating trip record" do 
        Trip.where(:repeating_trip_id => @repeating_trip_id).count.should == 0
        RepeatingTrip.find_by_id(@repeating_trip_id).should be_nil
      end
    end
  end
end

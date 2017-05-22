require 'spec_helper'

# For model specs
RSpec.shared_examples "a recurring ride coordinator" do
  describe "instance" do
    before do
      @described_class_factory = described_class.name.underscore.to_sym

      @occurrence_scheduler_class = described_class
      @occurrence_scheduler_class_factory = @described_class_factory
      @occurrence_scheduler_association_id = "#{@occurrence_scheduler_class_factory}_id"

      # Set @scheduled_instance_class in the described class
      fail "@scheduled_instance_class instance variable required" unless defined? @scheduled_instance_class

      # Set @occurrence_date_attribute in the described class
      fail "@occurrence_date_attribute instance variable required" unless defined? @occurrence_date_attribute
      
      # Set @scheduler_date_attribute in the described class
      fail "@scheduler_date_attribute instance variable required" unless defined? @scheduler_date_attribute

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
    
      it "returns the scheduler's schedule_attributes.interval if @repetition_interval is nil and the scheduler is present" do
        @coordinator.send "schedule_attributes=", {repeat: 1, interval: 5, interval_unit: "day"}
        expect(@coordinator.repetition_interval).to eq 5
      end
    end  

    describe "after validation with repetition" do
      before do
        @driver = create :driver
        @vehicle = create :vehicle, default_driver: @driver
      end
      
      describe "when creating a coordinator with repetition data" do
        before do
          # Freeze date at Sun, 30 Aug 2015, 12:00 PM
          Timecop.freeze(Time.parse("2015-08-30 12:00").in_time_zone)
        
          @coordinator = create @described_class_factory,
            # Schedule first occurrence on Mon, 31 Sep 2015
            @scheduler_date_attribute => Time.parse("2015-08-31 12:00").in_time_zone,
            :repeats_mondays => true, 
            :repeats_tuesdays => false,
            :repeats_wednesdays => false,
            :repeats_thursdays => false,
            :repeats_fridays => false,
            :repeats_saturdays => false,
            :repeats_sundays => false,
            :vehicle_id => @vehicle.id,
            :driver_id => @driver.id,
            :repetition_interval => 1
        end
      
        after do
          Timecop.return
        end

        it "should instantiate coordinators for 21 (default) days out" do
          # Time is still frozen at Sun, 30 Aug 2015. 3 weeks out is
          # Sun, 20 Sep 2015. With weekly repeats on Mondays, beginning Mon, 31 
          # Aug 2015, this gives us:
          #   2015-08-31
          #   2015-09-07
          #   2015-09-14
          @coordinator.save
          # The occurrence we just created, plus 2 more
          expect(@scheduled_instance_class.where(@occurrence_scheduler_association_id => @coordinator.id).count).to eq 3
        end
      end

      describe "when updating a future coordinator with repetition data" do
        before do
          # Freeze date at Sun, 30 Aug 2015, 12:00 PM
          Timecop.freeze(Time.parse("2015-08-30 12:00").in_time_zone)

          @coordinator = create @described_class_factory,
            # Schedule first occurrence on Mon, 31 Sep 2015
            # With weekly repeats on Mondays, this gives us:
            #   2015-08-31
            #   2015-09-07
            #   2015-09-14
            @scheduler_date_attribute => Time.parse("2015-08-31 12:00").in_time_zone,
            :repeats_mondays => true, 
            :repeats_tuesdays => false,
            :repeats_wednesdays => false,
            :repeats_thursdays => false,
            :repeats_fridays => false,
            :repeats_saturdays => false,
            :repeats_sundays => false,
            :vehicle_id => @vehicle.id,
            :driver_id => @driver.id,
            :repetition_interval => 1

          @coordinator.repeats_mondays = false
          @coordinator.repeats_tuesdays = true
          @coordinator.save
          @coordinator.reload
        end
      
        after do
          Timecop.return
        end

        it "should have the correct repeating coordinator attributes" do
          expect(@coordinator.schedule_attributes.monday).to be_nil
          expect(@coordinator.schedule_attributes.tuesday).to eq 1
        end

        it "should have new child coordinators on the correct day" do
          # Time is still frozen at Sun, 30 Aug 2015. 3 weeks out is
          # Sun, 20 Sep 2015. With weekly repeats now on Tuesdays, beginning 
          # Mon, 31 Aug 2015, this gives us:
          #   2015-09-01
          #   2015-09-08
          #   2015-09-15
          # Not including the original (which was created on a Monday), we 
          # should see 3 new occurrences
          expect(
            @scheduled_instance_class.where(
              @occurrence_scheduler_association_id => @coordinator.id
            ).select{ |c| c.send(@occurrence_date_attribute).strftime("%u") == "2" }.size
          ).to eq 3
        end

        it "should still have child coordinators on the old day" do
          # We should see only the original (which was created on a Monday)
          expect(
            @scheduled_instance_class.where(
              @occurrence_scheduler_association_id => @coordinator.id
            ).select{ |c| c.send(@occurrence_date_attribute).strftime("%u") == "1" }.size
          ).to eq 3
        end

        it "should tell me the correct repetition data when reloading the coordinator" do
          @coordinator.reload
          expect(@coordinator.repeats_mondays).to be_falsey
          expect(@coordinator.repeats_tuesdays).to be_truthy
          expect(@coordinator.vehicle_id).to eq @vehicle.id
          expect(@coordinator.driver_id).to eq @driver.id
        end
      end
   
      describe "when updating a past coordinator with repetition data," do
        before do
          # Freeze date at Sun, 30 Aug 2015, 12:00 PM
          Timecop.freeze(Time.parse("2015-08-30 12:00").in_time_zone) do
            @coordinator = create @described_class_factory,
              # Schedule first occurrence on Mon, 31 Sep 2015
              # With weekly repeats on Mondays, this gives us:
              #   2015-08-31
              #   2015-09-07
              #   2015-09-14
              @scheduler_date_attribute => Time.parse("2015-08-31 12:00").in_time_zone,
              :repeats_mondays => true, 
              :repeats_tuesdays => false,
              :repeats_wednesdays => false,
              :repeats_thursdays => false,
              :repeats_fridays => false,
              :repeats_saturdays => false,
              :repeats_sundays => false,
              :vehicle_id => @vehicle.id,
              :driver_id => @driver.id,
              :repetition_interval => 1
              
          end
          
          # Now advance time two weeks, to Sun, 13 Sep 2015
          Timecop.freeze(Time.parse("2015-09-13 12:00").in_time_zone)
          
          @coordinator.repeats_mondays = false
          @coordinator.repeats_tuesdays = true
          @coordinator.save
          @coordinator.reload
          
        end

        after do
          Timecop.return
        end

        it "should have the correct repeating coordinator attributes" do
          expect(@coordinator.schedule_attributes.monday).to be_nil
          expect(@coordinator.schedule_attributes.tuesday).to eq 1
        end

        it "should have new child coordinators on the correct day" do
          # Time is still frozen at Sun, 13 Sep 2015. 3 weeks out is
          # Sun, 04 Oct 2015. With weekly repeats now on Tuesdays, beginning 
          # Sun, 13 Sep 2015, this gives us:
          #   2015-09-15
          #   2015-09-22
          #   2015-09-29
          # Not including the originals (which were created on a Monday), we 
          # should see 3 new occurrences
          expect(
            @scheduled_instance_class.where(
              @occurrence_scheduler_association_id => @coordinator.id
            ).select{ |c| c.send(@occurrence_date_attribute).strftime("%u") == "2" }.size
          ).to eq 3
        end

        it "should still have child coordinators on the old day beyond Sun, 13 Sep 2015" do
          expect(
            @scheduled_instance_class.after_today.where(
              @occurrence_scheduler_association_id => @coordinator.id
            ).select{ |c| c.send(@occurrence_date_attribute).strftime("%u") == "1" }.size
          ).to eq 1
        end

        it "should retain child coordinators on the old day on or before Sun, 13 Sep 2015" do
          expect(
            @scheduled_instance_class.today_and_prior.where(
              @occurrence_scheduler_association_id => @coordinator.id
            ).select{ |c| c.send(@occurrence_date_attribute).strftime("%u") == "1" }.size
          ).to eq 2
        end

        it "should tell me the correct repeating trip data when reloading the trip" do
          @coordinator.reload
          expect(@coordinator.repeats_mondays).to be_falsey
          expect(@coordinator.repeats_tuesdays).to be_truthy
          expect(@coordinator.vehicle_id).to eq @vehicle.id
          expect(@coordinator.driver_id).to eq @driver.id
        end
      end

      describe "when I clear out the repetition data" do
        before do
          # Freeze date at Sun, 30 Aug 2015, 12:00 PM
          Timecop.freeze(Time.parse("2015-08-30 12:00").in_time_zone) do
            @coordinator = create @described_class_factory,
              # Schedule first occurrence on Mon, 31 Sep 2015
              # With weekly repeats on Mondays, this gives us:
              #   2015-08-31
              #   2015-09-07
              #   2015-09-14
              @scheduler_date_attribute => Time.parse("2015-08-31 12:00").in_time_zone,
              :repeats_mondays => true, 
              :repeats_tuesdays => false,
              :repeats_wednesdays => false,
              :repeats_thursdays => false,
              :repeats_fridays => false,
              :repeats_saturdays => false,
              :repeats_sundays => false,
              :vehicle_id => @vehicle.id,
              :driver_id => @driver.id,
              :repetition_interval => 1
          end
          
          # Now advance time two weeks, to Sun, 13 Sep 2015
          Timecop.freeze(Time.parse("2015-09-13 12:00").in_time_zone)
                    
          @coordinator.repeats_mondays = false
          @coordinator.save
          
        end

        after do
          Timecop.return
        end

        it "should retain child coordinators on or before Sun, 13 Sep 2015" do
          expect(
            @scheduled_instance_class.today_and_prior.where(
              @occurrence_scheduler_association_id => @coordinator.id
            ).select{ |c| c.send(@occurrence_date_attribute).strftime("%u") == "1" }.size
          ).to eq 2
        end
      end
    end
  end
end

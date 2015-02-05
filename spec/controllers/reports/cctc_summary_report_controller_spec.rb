require 'spec_helper'

describe ReportsController do
  describe "cctc_summary_report" do
    before :each do
      @test_user = create_role(level: 100).user
      @test_provider = @test_user.current_provider
    
      @test_funding_sources = {}
      @test_funding_sources[:oaa3b]        = @test_provider.funding_sources.create(:name => "OAA")
      @test_funding_sources[:trimet]       = @test_provider.funding_sources.create(:name => "TriMet Non-Medical")
      @test_funding_sources[:rc]           = @test_provider.funding_sources.create(:name => "Ride Connection")
      @test_funding_sources[:stf]          = @test_provider.funding_sources.create(:name => "STF")
      @test_funding_sources[:unreimbursed] = @test_provider.funding_sources.create(:name => "Unreimbursed")
    
      @test_start_date = DateTime.new(2013, 2, 1).in_time_zone
    
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in @test_user
    end

    it "is successful" do
      get :cctc_summary_report
      response.should be_success
    end

    it "assigns the proper instance variables" do
      get :cctc_summary_report, query: {start_date: @test_start_date.to_date.to_s}
      assigns(:provider).should eq(@test_provider)
      assigns(:start_date).should eq(@test_start_date.to_date)
      assigns(:report).should_not be_nil
    end

    describe "total_miles" do
      before do
        # In report range
        create_trip(provider: @test_provider, mileage: 1, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date, cab: false)
        create_trip(provider: @test_provider, mileage: 1, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date, cab: true)
        create_trip(provider: @test_provider, mileage: 1, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date)
        
        # Outside report range
        create_trip(provider: @test_provider, mileage: 1, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month, cab: false)
        create_trip(provider: @test_provider, mileage: 1, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month, cab: true)
        create_trip(provider: @test_provider, mileage: 1, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date - 1.month)

        get :cctc_summary_report, query: {start_date: @test_start_date.to_date.to_s}
      end
      
      # TODO This test is failing on master. Uncomment after upgrade. Fix if
      # time allows.
      # it "reports the proper mileage" do
      #   assigns(:report)[:total_miles][:stf][:van_bus].should eq(1)
      #   assigns(:report)[:total_miles][:stf][:taxi].should eq(1)
      #   assigns(:report)[:total_miles][:rc].should eq(1)
      # end
    end
    
    describe "rider_information" do
      before do
        # Existing customers (by virtue of having trips before current report date range)
        ec_1 = create_customer(birth_date: @test_start_date - 59.years, ada_eligible: true)  # under 60, ADA eligible
        ec_2 = create_customer(birth_date: @test_start_date - 59.years, ada_eligible: false) # under 60, ADA ineligible
        ec_3 = create_customer(birth_date: @test_start_date - 61.years, ada_eligible: true)  # over 60, ADA eligible
        ec_4 = create_customer(birth_date: @test_start_date - 61.years, ada_eligible: false) # over 60, ADA ineligible
        
        # New customers (by virtue of not having any trips before current report date range)
        nc_1 = create_customer(birth_date: @test_start_date - 59.years, ada_eligible: true)  # under 60, ADA eligible
        nc_2 = create_customer(birth_date: @test_start_date - 59.years, ada_eligible: false) # under 60, ADA ineligible
        nc_3 = create_customer(birth_date: @test_start_date - 61.years, ada_eligible: true)  # over 60, ADA eligible
        nc_4 = create_customer(birth_date: @test_start_date - 61.years, ada_eligible: false) # over 60, ADA ineligible
        
        # Rides for existing customers, in report range
        create_trip(provider: @test_provider, customer: ec_1, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: ec_2, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: ec_3, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: ec_4, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)

        create_trip(provider: @test_provider, customer: ec_1, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: ec_2, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: ec_3, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: ec_4, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date)

        # Rides for existing customers, in YTD range
        create_trip(provider: @test_provider, customer: ec_1, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, customer: ec_2, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, customer: ec_3, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, customer: ec_4, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month)

        create_trip(provider: @test_provider, customer: ec_1, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, customer: ec_2, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, customer: ec_3, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, customer: ec_4, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date - 1.month)

        # Rides for existing customers, outside report range
        create_trip(provider: @test_provider, customer: ec_1, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.year)
        create_trip(provider: @test_provider, customer: ec_2, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.year)
        create_trip(provider: @test_provider, customer: ec_3, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.year)
        create_trip(provider: @test_provider, customer: ec_4, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.year)

        create_trip(provider: @test_provider, customer: ec_1, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date - 1.year)
        create_trip(provider: @test_provider, customer: ec_2, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date - 1.year)
        create_trip(provider: @test_provider, customer: ec_3, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date - 1.year)
        create_trip(provider: @test_provider, customer: ec_4, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date - 1.year)

        # Rides for new customers, in report range
        create_trip(provider: @test_provider, customer: nc_1, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: nc_2, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: nc_3, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: nc_4, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)

        create_trip(provider: @test_provider, customer: nc_1, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: nc_2, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: nc_3, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: nc_4, funding_source: @test_funding_sources[:rc], pickup_time: @test_start_date)
        
        get :cctc_summary_report, query: {start_date: @test_start_date.to_date.to_s}
      end
      
      describe "riders_new_this_month" do
        it "reports the correct number of new riders" do
          assigns(:report)[:rider_information][:riders_new_this_month][:over_60][:stf].should eq(2)
          assigns(:report)[:rider_information][:riders_new_this_month][:over_60][:rc].should eq(2)

          assigns(:report)[:rider_information][:riders_new_this_month][:under_60][:stf].should eq(2)
          assigns(:report)[:rider_information][:riders_new_this_month][:under_60][:rc].should eq(2)

          assigns(:report)[:rider_information][:riders_new_this_month][:ada_eligible][:over_60].should eq(2)
          assigns(:report)[:rider_information][:riders_new_this_month][:ada_eligible][:under_60].should eq(2)
        end        
      end

      describe "riders_ytd" do
        it "reports the correct number of new riders ytd" do
          assigns(:report)[:rider_information][:riders_ytd][:over_60][:stf].should eq(4)
          assigns(:report)[:rider_information][:riders_ytd][:over_60][:rc].should eq(4)

          assigns(:report)[:rider_information][:riders_ytd][:under_60][:stf].should eq(4)
          assigns(:report)[:rider_information][:riders_ytd][:under_60][:rc].should eq(4)

          assigns(:report)[:rider_information][:riders_ytd][:ada_eligible][:over_60].should eq(2)
          assigns(:report)[:rider_information][:riders_ytd][:ada_eligible][:under_60].should eq(2)
        end        
      end
    end
    
    describe "driver_information" do
      before do
        # Driver -> Run -> Trip
        
        # Existing Drivers (by virtue of having given rides before current report date range)
        ed_1 = create_driver(provider: @test_provider, paid: true )
        ed_2 = create_driver(provider: @test_provider, paid: false)

        # New Drivers (by virtue of not having given any rides before current report date range)
        nd_1 = create_driver(provider: @test_provider, paid: true)
        nd_2 = create_driver(provider: @test_provider, paid: false)
        
        # Runs for existing drivers, in report range
        r_1 = Run.create(provider: @test_provider, driver: ed_1, paid: true,  date: @test_start_date, actual_start_time: @test_start_date, actual_end_time: @test_start_date + 30.minutes, unpaid_driver_break_time: 5)
        r_2 = Run.create(provider: @test_provider, driver: ed_2, paid: false, date: @test_start_date, actual_start_time: @test_start_date, actual_end_time: @test_start_date + 30.minutes, unpaid_driver_break_time: 5)

        # Runs for existing drivers, outside report range
        r_3 = Run.create(provider: @test_provider, driver: ed_1, paid: true,  date: @test_start_date - 1.month, actual_start_time: @test_start_date - 1.month, actual_end_time: @test_start_date - 1.month + 30.minutes, unpaid_driver_break_time: 5)
        r_4 = Run.create(provider: @test_provider, driver: ed_2, paid: false, date: @test_start_date - 1.month, actual_start_time: @test_start_date - 1.month, actual_end_time: @test_start_date - 1.month + 30.minutes, unpaid_driver_break_time: 5)

        # Runs for new drivers, in report range
        r_5 = Run.create(provider: @test_provider, driver: nd_1, paid: true,  date: @test_start_date, actual_start_time: @test_start_date, actual_end_time: @test_start_date + 30.minutes, unpaid_driver_break_time: 5)
        r_6 = Run.create(provider: @test_provider, driver: nd_2, paid: false, date: @test_start_date, actual_start_time: @test_start_date, actual_end_time: @test_start_date + 30.minutes, unpaid_driver_break_time: 5)

        # Rides for existing drivers, in report range
        create_trip(provider: @test_provider, run: r_1, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, run: r_2, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, run: r_1, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date)
        create_trip(provider: @test_provider, run: r_2, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date)

        # Rides for existing drivers, outside report range
        create_trip(provider: @test_provider, run: r_3, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, run: r_4, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, run: r_3, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, run: r_4, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date - 1.month)

        # Rides for new drivers, in report range
        create_trip(provider: @test_provider, run: r_5, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, run: r_6, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, run: r_5, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date)
        create_trip(provider: @test_provider, run: r_6, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date)

        get :cctc_summary_report, query: {start_date: @test_start_date.to_date.to_s}
      end
      
      describe "number_of_driver_hours" do
        it "reports the correct number of new driver hours" do
          assigns(:report)[:driver_information][:number_of_driver_hours][:paid][:stf].should eq(0.84)
          assigns(:report)[:driver_information][:number_of_driver_hours][:paid][:rc].should eq(0.84)

          assigns(:report)[:driver_information][:number_of_driver_hours][:volunteer][:stf].should eq(0.84)
          assigns(:report)[:driver_information][:number_of_driver_hours][:volunteer][:rc].should eq(0.84)
        end        
      end

      describe "number_of_active_drivers" do
        it "reports the correct number of active drivers" do
          assigns(:report)[:driver_information][:number_of_active_drivers][:paid][:stf].should eq(2)
          assigns(:report)[:driver_information][:number_of_active_drivers][:paid][:rc].should eq(2)

          assigns(:report)[:driver_information][:number_of_active_drivers][:volunteer][:stf].should eq(2)
          assigns(:report)[:driver_information][:number_of_active_drivers][:volunteer][:rc].should eq(2)
        end        
      end

      describe "drivers_new_this_month" do
        it "reports the correct number of new drivers" do
          assigns(:report)[:driver_information][:drivers_new_this_month][:paid][:stf].should eq(1)
          assigns(:report)[:driver_information][:drivers_new_this_month][:paid][:rc].should eq(1)

          assigns(:report)[:driver_information][:drivers_new_this_month][:volunteer][:stf].should eq(1)
          assigns(:report)[:driver_information][:drivers_new_this_month][:volunteer][:rc].should eq(1)
        end        
      end

      describe "escort_hours" do
        skip "Pending completion of ticket 1501"
      end

      describe "administrative_hours" do
        skip "Pending completion of ticket 1501"
      end
    end
    
    describe "rides_not_given" do
      before do
        # In report range
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date, trip_result: "TD")
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date, trip_result: "TD")
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date, trip_result: "CANC")
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date, trip_result: "CANC")
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date, trip_result: "NS")
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date, trip_result: "NS")

        # Outside report range
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month, trip_result: "TD")
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date - 1.month, trip_result: "TD")
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month, trip_result: "CANC")
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date - 1.month, trip_result: "CANC")
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month, trip_result: "NS")
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date - 1.month, trip_result: "NS")

        get :cctc_summary_report, query: {start_date: @test_start_date.to_date.to_s}
      end
      
      describe "turndowns" do
        it "reports the correct number of turned-down trips" do
          assigns(:report)[:rides_not_given][:turndowns][:stf].should eq(1)
          assigns(:report)[:rides_not_given][:turndowns][:rc].should eq(1)
        end
      end

      describe "cancels" do
        it "reports the correct number of canceled trips" do
          assigns(:report)[:rides_not_given][:cancels][:stf].should eq(1)
          assigns(:report)[:rides_not_given][:cancels][:rc].should eq(1)
        end
      end

      describe "no_shows" do
        it "reports the correct number of no-show trips" do
          assigns(:report)[:rides_not_given][:no_shows][:stf].should eq(1)
          assigns(:report)[:rides_not_given][:no_shows][:rc].should eq(1)
        end
      end
    end
    
    describe "rider_donations" do
      before do
        # In report range
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date, donation: 1.23)
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date, donation: 1.23)

        # Outside report range
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month, donation: 1.23)
        create_trip(provider: @test_provider, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date - 1.month, donation: 1.23)

        get :cctc_summary_report, query: {start_date: @test_start_date.to_date.to_s}
      end
      
      it "reports the correct amount of donations" do
        assigns(:report)[:rider_donations][:stf].should eq(1.23)
        assigns(:report)[:rider_donations][:rc].should eq(1.23)
      end
    end
    
    describe "trip_purposes" do
      before do
        # trip_purposes: {trips: [], total_rides: {}, reimbursements_due: {}}, # We will loop over and add these later
        @test_provider.oaa3b_per_ride_reimbursement_rate = 1.23
        @test_provider.ride_connection_per_ride_reimbursement_rate = 1.23
        @test_provider.trimet_per_ride_reimbursement_rate = 1.23
        @test_provider.stf_van_per_ride_reimbursement_rate = 1.23
        @test_provider.stf_taxi_per_ride_wheelchair_load_fee = 1.23
        @test_provider.stf_taxi_per_mile_wheelchair_reimbursement_rate = 1.23
        @test_provider.stf_taxi_per_ride_ambulatory_load_fee = 1.23
        @test_provider.stf_taxi_per_mile_ambulatory_reimbursement_rate = 1.23
        @test_provider.stf_taxi_per_ride_administrative_fee = 1.23
        @test_provider.save!
        
        TRIP_PURPOSES.each do |trip_purpose|
          @test_funding_sources.keys.reject{|k| k == :stf}.each do |funding_source|
            # In report range, 
            create_trip(provider: @test_provider, funding_source: @test_funding_sources[funding_source], pickup_time: @test_start_date, trip_purpose: trip_purpose)
            create_trip(provider: @test_provider, funding_source: @test_funding_sources[funding_source], pickup_time: @test_start_date, trip_purpose: trip_purpose, round_trip: true)
          
            # Outside report range
            create_trip(provider: @test_provider, funding_source: @test_funding_sources[funding_source], pickup_time: @test_start_date - 1.month, trip_purpose: trip_purpose)
            create_trip(provider: @test_provider, funding_source: @test_funding_sources[funding_source], pickup_time: @test_start_date - 1.month, trip_purpose: trip_purpose, round_trip: true)
          end
          
          # STF taxi rides, in report range
          create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date, trip_purpose: trip_purpose, service_level: "Wheelchair", mileage: 1, cab: true)
          create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date, trip_purpose: trip_purpose, service_level: "Wheelchair", mileage: 1, cab: true, round_trip: true)
          create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date, trip_purpose: trip_purpose, service_level: "Ambulatory", mileage: 1, cab: true)
          create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date, trip_purpose: trip_purpose, service_level: "Ambulatory", mileage: 1, cab: true, round_trip: true)
          
          # STF taxi rides, outside report range
          create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month, trip_purpose: trip_purpose, service_level: "Wheelchair", mileage: 1, cab: true)
          create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month, trip_purpose: trip_purpose, service_level: "Wheelchair", mileage: 1, cab: true, round_trip: true)
          create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month, trip_purpose: trip_purpose, service_level: "Ambulatory", mileage: 1, cab: true)
          create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month, trip_purpose: trip_purpose, service_level: "Ambulatory", mileage: 1, cab: true, round_trip: true)
          
          # STF non-taxi rides, in report range
          create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date, trip_purpose: trip_purpose)
          create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date, trip_purpose: trip_purpose, round_trip: true)
          
          # STF non-taxi rides, outside report range
          create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month, trip_purpose: trip_purpose)
          create_trip(provider: @test_provider, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month, trip_purpose: trip_purpose, round_trip: true)          
        end
        
        get :cctc_summary_report, query: {start_date: @test_start_date.to_date.to_s}
      end
      
      describe "trips" do
        it "reports the correct trip purpose data" do
          assigns(:report)[:trip_purposes][:trips].collect{|t| t[:name]}.should =~ TRIP_PURPOSES
          
          assigns(:report)[:trip_purposes][:trips].each do |trip|
            @test_funding_sources.keys.reject{|k| k == :stf}.each do |funding_source|
              trip[funding_source].should eq(3)
            end

            # STF taxi rides
            trip[:stf_taxi][:all][:count].should eq(6)
            trip[:stf_taxi][:all][:mileage].should eq(4)
            
            trip[:stf_taxi][:wheelchair][:count].should eq(3)
            trip[:stf_taxi][:wheelchair][:mileage].should eq(2)
            
            trip[:stf_taxi][:ambulatory][:count].should eq(3)
            trip[:stf_taxi][:ambulatory][:mileage].should eq(2)
            
            # STF non-taxi rides
            trip[:stf_van].should eq(3)
            
            # Total rides
            trip[:total_rides].should eq(21)
          end
        end
      end

      describe "total_rides" do
        it "reports the correct number of total rides" do
          @test_funding_sources.keys.reject{|k| k == :stf}.each do |funding_source|
            assigns(:report)[:trip_purposes][:total_rides][funding_source].should eq(TRIP_PURPOSES.size * 3)
          end
          
          assigns(:report)[:trip_purposes][:total_rides][:stf_taxi].should eq(TRIP_PURPOSES.size * 6)
          assigns(:report)[:trip_purposes][:total_rides][:stf_van].should eq(TRIP_PURPOSES.size * 3)
        end
      end

      describe "reimbursements_due" do
        it "reports the correct reimbursement amounts due" do
          assigns(:report)[:trip_purposes][:reimbursements_due][:oaa3b].should eq(1.23 * TRIP_PURPOSES.size * 3)
          assigns(:report)[:trip_purposes][:reimbursements_due][:rc].should eq(1.23 * TRIP_PURPOSES.size * 3)
          assigns(:report)[:trip_purposes][:reimbursements_due][:trimet].should eq(1.23 * TRIP_PURPOSES.size * 3)
          assigns(:report)[:trip_purposes][:reimbursements_due][:stf_van].should eq(1.23 * TRIP_PURPOSES.size * 3)

          assigns(:report)[:trip_purposes][:reimbursements_due][:stf_taxi].should eq(
            (TRIP_PURPOSES.size * 3 * 1.23) +
            (TRIP_PURPOSES.size * 2 * 1.23) +
            (TRIP_PURPOSES.size * 3 * 1.23) +
            (TRIP_PURPOSES.size * 2 * 1.23) +
            (TRIP_PURPOSES.size * 6 * 1.23)
          )
        end
      end
    end
    
    describe "new_rider_ethinic_heritage" do
      before do
        e_1 = @test_provider.ethnicities.create(:name => "Ethnicity 1")
        e_2 = @test_provider.ethnicities.create(:name => "Ethnicity 2")
        e_3 = @test_provider.ethnicities.create(:name => "Other")
        
        c_1 = create_customer(ethnicity: e_1.name)
        c_2 = create_customer(ethnicity: e_2.name)
        c_3 = create_customer(ethnicity: e_3.name)
        c_4 = create_customer(ethnicity: "Something Else")

        # In report range
        create_trip(provider: @test_provider, customer: c_1, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: c_1, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: c_2, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: c_2, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: c_3, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: c_3, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: c_4, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date)
        create_trip(provider: @test_provider, customer: c_4, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date)
        
        # Outside report range
        create_trip(provider: @test_provider, customer: c_1, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, customer: c_1, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, customer: c_2, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, customer: c_2, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, customer: c_3, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, customer: c_3, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, customer: c_4, funding_source: @test_funding_sources[:stf], pickup_time: @test_start_date - 1.month)
        create_trip(provider: @test_provider, customer: c_4, funding_source: @test_funding_sources[:rc],  pickup_time: @test_start_date - 1.month)

        get :cctc_summary_report, query: {start_date: @test_start_date.to_date.to_s}
      end
      
      describe "ethnicities" do
        it "reports the correct ethnicity information" do
          assigns(:report)[:new_rider_ethinic_heritage][:ethnicities].collect{|e| e[:name]}.should =~ @test_provider.ethnicities.collect(&:name)
                    
          @test_provider.ethnicities.reject{|e| e.name == "Other"}.each do |ethnicity|
            e = assigns(:report)[:new_rider_ethinic_heritage][:ethnicities].find{|e| e[:name] == ethnicity.name}
            e.should_not be_nil
            e[:trips][:rc].should eq(1)
            e[:trips][:stf].should eq(1)
          end
          
          e = assigns(:report)[:new_rider_ethinic_heritage][:ethnicities].find{|e| e[:name] == "Other"}
          e.should_not be_nil
          e[:trips][:rc].should eq(2)
          e[:trips][:stf].should eq(2)
        end
      end
    end
  end
end

require 'spec_helper'

describe CabTripsController do
  before :each do
    @user = create_role(level: 100).user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in @user
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'edit_multiple'" do
    it "should be successful" do
      get 'edit_multiple'
      response.should be_success
    end
  end
  
  describe "PUT 'update_multiple'" do
    before do
      @start_date = Time.now.beginning_of_week.to_date.to_time_in_current_zone.utc
      @end_date = @start_date + 6.days
      @t1 = create_trip provider: @user.current_provider, cab: true, pickup_time: @start_date, attendant_count: 0
      @t2 = create_trip provider: @user.current_provider, cab: true, pickup_time: @start_date, attendant_count: 0
      cab_trip_params = {
        @t1.id => {
          attendant_count: 1
        },
        @t2.id => {
          attendant_count: 2
        }
      }
      put 'update_multiple', cab_trips: cab_trip_params
    end
    
    it "should be successful" do
      response.should redirect_to(cab_trips_path(start: @start_date.to_time.to_i, end: @end_date.to_time.to_i))
    end
    
    it "should update the submitted trips" do
      Trip.find(@t1.id).attendant_count.should == 1
      Trip.find(@t2.id).attendant_count.should == 2
    end
  end
end
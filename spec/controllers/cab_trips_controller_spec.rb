require "rails_helper"

RSpec.describe CabTripsController do
  before :each do
    @user = create(:role, level: 100).user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in @user
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      expect(response).to be_success
    end
  end

  describe "GET 'edit_multiple'" do
    it "should be successful" do
      get 'edit_multiple'
      expect(response).to be_success
    end
  end
  
  describe "PUT 'update_multiple'" do
    before do
      @start_date = Time.now.beginning_of_week.to_date.in_time_zone.utc
      @end_date = @start_date + 6.days
      @t1 = create :trip, provider: @user.current_provider, cab: true, pickup_time: @start_date, attendant_count: 0
      @t2 = create :trip, provider: @user.current_provider, cab: true, pickup_time: @start_date, attendant_count: 0
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
    
    # TODO This test is currently failing due to timezone strangeness. Ignoring
    # for now, and will fix if it's still an issue in Rails 3.2 or 4.0. See:
    # http://stackoverflow.com/q/24759900/83743
    it "should be successful" do
      expect(response).to redirect_to(cab_trips_path(start: @start_date.to_time.to_i, end: @end_date.to_time.to_i))
    end
    
    it "should update the submitted trips" do
      expect(Trip.find(@t1.id).attendant_count).to eq(1)
      expect(Trip.find(@t2.id).attendant_count).to eq(2)
    end
  end
end
require 'spec_helper'

describe "CabTrips" do
  context "for admin" do
    before do
      @user = create_role(level: 100).user
      visit new_user_session_path
      fill_in 'user_email', with: @user.email
      fill_in 'Password', with: 'password#1'
      click_button 'Sign in'
      
      @start_date = Time.now.beginning_of_week.to_date.to_time_in_current_zone.utc
      @end = @start_date + 6.days
      @t1 = create_trip provider: @user.current_provider, cab: true, pickup_time: @start_date
      @t2 = create_trip provider: @user.current_provider, cab: true, pickup_time: @start_date
      create_trip provider: @user.current_provider, cab: true, pickup_time: @start_date + 1.day
      create_trip provider: @user.current_provider, cab: true, pickup_time: @start_date + 1.day
      create_trip provider: @user.current_provider, cab: true, pickup_time: @start_date + 3.days
    end
    
    describe "GET /cab_trips" do
      before do
        visit cab_trips_path(start: @start_date.to_i)
      end
      
      it "has a link to edit the trips occuring on the 1st, 2nd and 4th day of the week" do
        page.should have_link("Edit 2 cab trips", href: edit_multiple_cab_trips_path(start: @start_date.to_i))
        page.should have_link("Edit 2 cab trips", href: edit_multiple_cab_trips_path(start: (@start_date + 1.day).to_i))
        page.should have_link("Edit 1 cab trip", href: edit_multiple_cab_trips_path(start: (@start_date + 3.day).to_i))
      end
      
      # TODO This test is failing on master. Uncomment after upgrade. Fix if
      # time allows.
      # it "doesn't have a link to edit trips on the 3rd, 5th, 6th, and 7th day of the week" do
      #   page.should have_selector("#cab_trips tr:nth-child(4)", content: "No cab trips")
      #   page.should have_selector("#cab_trips tr:nth-child(6)", content: "No cab trips")
      #   page.should have_selector("#cab_trips tr:nth-child(7)", content: "No cab trips")
      #   page.should have_selector("#cab_trips tr:nth-child(8)", content: "No cab trips")
      # end
    end
  
    describe "GET /cab_trips/edit_multiple" do
      before do
        visit edit_multiple_cab_trips_path(start: @start_date.to_i)
      end
    
      it "displays the trips occuring on the specified date" do
        page.should have_selector("#cab_trips_#{@t1.id}_attendant_count")
        page.should have_selector("#cab_trips_#{@t2.id}_attendant_count")
      end
    
      it "should update the specified trips" do
        fill_in("cab_trips_#{@t1.id}_attendant_count", with: 1)
        fill_in("cab_trips_#{@t2.id}_attendant_count", with: 2)
        click_button "Update cab trips"
        page.should have_content("2 cab trips updated successfully")
      end
    end
  end
end

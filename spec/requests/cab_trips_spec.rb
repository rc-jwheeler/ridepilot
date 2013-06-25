require 'spec_helper'

describe "CabTrips" do
  context "for admin" do
    before do
      @user = create_role(level: 100).user
      visit new_user_session_path
      fill_in 'user_email', with: @user.email
      fill_in 'Password', with: 'password#1'
      click_button 'Sign in'
    end
    
    describe "GET /cab_trips" do
      before do
        @start_date = Time.now.beginning_of_week.to_date.to_time_in_current_zone.utc
        create_trip provider: @user.current_provider, cab: true, pickup_time: @start_date
        create_trip provider: @user.current_provider, cab: true, pickup_time: @start_date
        create_trip provider: @user.current_provider, cab: true, pickup_time: @start_date + 1.day
        create_trip provider: @user.current_provider, cab: true, pickup_time: @start_date + 1.day
        create_trip provider: @user.current_provider, cab: true, pickup_time: @start_date + 3.days
        visit cab_trips_path(start: @start_date.to_i)
      end
      
      it "has a link to edit the trips occuring on the 1st, 2nd and 4th day of the week" do
        page.should have_link("Edit 2 cab trips", href: edit_multiple_cab_trips_path(for_date: @start_date.to_i))
        page.should have_link("Edit 2 cab trips", href: edit_multiple_cab_trips_path(for_date: (@start_date + 1.day).to_i))
        page.should have_link("Edit 1 cab trip", href: edit_multiple_cab_trips_path(for_date: (@start_date + 3.day).to_i))
      end
      
      it "doesn't have a link to edit trips on the 3rd, 5th, 6th, and 7th day of the week" do
        page.should have_selector("#cab_trips tbody tr:nth-child(3)", content: "No cab trips")
        page.should have_selector("#cab_trips tbody tr:nth-child(5)", content: "No cab trips")
        page.should have_selector("#cab_trips tbody tr:nth-child(6)", content: "No cab trips")
        page.should have_selector("#cab_trips tbody tr:nth-child(7)", content: "No cab trips")
      end
    end
  end
end

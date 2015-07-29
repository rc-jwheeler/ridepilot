require "rails_helper"

RSpec.describe "DriverCompliances" do
  context "for admin" do
    before :each do
      @admin = create(:admin)
      visit new_user_session_path
      fill_in 'Email', :with => @admin.email
      fill_in 'Password', :with => @admin.password
      click_button 'Log In'
      
      @driver = create :driver, :provider => @admin.current_provider
      create :driver_compliance, driver: @driver
    end
    
    describe "GET /drivers/:id/edit" do
      before do
        visit edit_driver_path(id: @driver.to_param)
      end
      
      it "shows the existing compliance event and a new compliance event" do
        expect(page).to have_selector ".driver-compliance-fields", count: 2
      end
      
      # TODO Pending acceptance and merge of capybara_js branch into develop
      skip "has a link to add new compliance events", js: true do
        click_link "Add event"
        expect(page).to have_selector ".driver-compliance-fields", count: 3
      end
      
      # TODO Pending acceptance and merge of capybara_js branch into develop
      skip "has a link to remove existing compliance events", js: true do
        all(:link, "Remove this event").first.click
        expect(page).to have_selector ".driver-compliance-fields", count: 2
        expect(find("#driver_driver_compliance_attributes_0__destroy", visible: false).val()).to eql "1"
      end
    end
  end
end

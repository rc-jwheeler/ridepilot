require "rails_helper"

RSpec.describe Driver, type: :model do
  it "cannot be linked to the same user as another driver" do
    driver_1 = create :driver
    driver_2 = build :driver, user: driver_1.user
    expect(driver_2.valid?).to be_falsey
    expect(driver_2.errors.keys).to include :user_id

    driver_2.user = create :user
    expect(driver_2.valid?).to be_truthy
  end

  it "must have a unique name within the scope of its provider" do
    driver_1 = create :driver
    driver_2 = build :driver, name: driver_1.name, provider: driver_1.provider
    expect(driver_2.valid?).to be_falsey
    expect(driver_2.errors.keys).to include :name

    driver_2.provider = create :provider
    expect(driver_2.valid?).to be_truthy
  end

  it "must have a name at least 2 characters in length" do
    driver = build :driver, name: "M"
    expect(driver.valid?).to be_falsey
    expect(driver.errors.keys).to include :name

    driver.name = "Mo"
    expect(driver.valid?).to be_truthy
  end

  it "must have a valid email when specified" do
    driver = build :driver, email: "m@m"
    expect(driver.valid?).to be_falsey
    expect(driver.errors.keys).to include :email

    driver.email = "m@m.m"
    expect(driver.valid?).to be_truthy
  end

  it "can find drivers for a given provider" do
    driver_1 = create :driver
    driver_2 = create :driver
    drivers = Driver.for_provider driver_1.provider
    expect(drivers).to include driver_1
    expect(drivers).not_to include driver_2
  end

  it "can find drivers who are not assigned to a device pool" do
    provider = create :provider
    driver_1 = create :driver, provider: provider
    driver_2 = create :driver, provider: provider
    create :device_pool_driver, driver: driver_1, device_pool: create(:device_pool, provider: provider)
    unassigned = Driver.unassigned provider
    expect(unassigned).not_to include driver_1
    expect(unassigned).to include driver_2
  end
  
  it "can generate a hash of the driver's operating hours" do
    driver = create :driver
    hours = create :operating_hours, driver: driver, day_of_week: 0, start_time: "01:00", end_time: "02:00"
    expect(driver.hours_hash[0]).to eql hours
  end
  
  describe "available?" do
    before do
      @driver = create :driver
      @day_of_week = 0
      @time_of_day = "15:30"
    end
    
    it "returns true if no operating hours are defined" do
      expect(@driver.available?).to be_truthy
    end
    
    it "returns false if operating hours are defined, but not for that day" do
      create :operating_hours, driver: @driver, day_of_week: @day_of_week + 1
      expect(@driver.available?(day_of_week: @day_of_week, time_of_day: @time_of_day)).to be_falsey
    end
    
    it "returns true if the driver is available 24 hours" do
      create :operating_hours, driver: @driver, day_of_week: @day_of_week, start_time: "00:00", end_time: "00:00"
      expect(@driver.available?(day_of_week: @day_of_week, time_of_day: @time_of_day)).to be_truthy
    end
    
    it "returns false if the driver is not available that day" do
      create :operating_hours, driver: @driver, day_of_week: @day_of_week, start_time: nil, end_time: nil
      expect(@driver.available?(day_of_week: @day_of_week, time_of_day: @time_of_day)).to be_falsey
    end
    
    it "can check against regular hours" do
      hours = create :operating_hours, driver: @driver, day_of_week: @day_of_week, start_time: "12:00", end_time: "16:00"
      expect(@driver.available?(day_of_week: @day_of_week, time_of_day: @time_of_day)).to be_truthy
      
      hours.update_attributes end_time: "15:00"
      expect(@driver.available?(day_of_week: @day_of_week, time_of_day: @time_of_day)).to be_falsey
    end
    
    it "can check against irregular hours" do
      hours = create :operating_hours, driver: @driver, day_of_week: @day_of_week, start_time: "12:00", end_time: "02:00"
      expect(@driver.available?(day_of_week: @day_of_week, time_of_day: @time_of_day)).to be_truthy
      
      hours.update_attributes start_time: "16:00"
      expect(@driver.available?(day_of_week: @day_of_week, time_of_day: @time_of_day)).to be_falsey
    end
  end
  
  describe "driver_histories" do
    before do
      @driver = create :driver
    end
    
    it "accepts nested driver histories" do
      @driver.driver_histories_attributes = 3.times.collect { attributes_for :driver_history, driver: @driver }
      expect {
        @driver.save
      }.to change(DriverHistory, :count).by(3)
    end

    it "allows destroy attribute" do
      3.times { create :driver_history, driver: @driver }
      expect(@driver.driver_histories.count).to eql 3
      
      @driver.driver_histories_attributes = @driver.driver_histories.collect { |history| history.attributes.merge({:_destroy => "1"}) }
      expect {
        @driver.save
      }.to change(DriverHistory, :count).by(-3)
    end
    
    it "rejects a history with a blank event" do
      @driver.driver_histories_attributes = [ attributes_for(:driver_history, driver: @driver, event: nil) ]
      expect {
        @driver.save
      }.not_to change(DriverHistory, :count)
    end
  end
end

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
end

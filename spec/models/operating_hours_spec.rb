require 'rails_helper'

RSpec.describe OperatingHours, type: :model do
  it "requires a day of the week" do
    hours = build :operating_hours, day_of_week: nil
    expect(hours.valid?).to be_falsey
    expect(hours.errors.keys).to include :day_of_week
  end

  it "requires a driver" do
    hours = build :operating_hours, driver: nil
    expect(hours.valid?).to be_falsey
    expect(hours.errors.keys).to include :driver
  end
  
  it "orders records by day_of_week" do
    hours_5 = create :operating_hours, day_of_week: 5
    hours_1 = create :operating_hours, day_of_week: 1
    hours_3 = create :operating_hours, day_of_week: 3
    hours_0 = create :operating_hours, day_of_week: 0
    
    expect(OperatingHours.all.to_a).to eql [hours_0, hours_1, hours_3, hours_5]
  end
  
  it "allow hours such as 12:00pm - 3:00am" do
    hours = build :operating_hours, start_time: "12:00", end_time: "02:59"
    expect(hours.valid?).to be_truthy
    expect(hours.is_regular_hours?).to be_truthy
  end
  
  it "can be unavailable" do
    hours = build :operating_hours, start_time: nil, end_time: nil
    expect(hours.valid?).to be_truthy
    expect(hours.is_unavailable?).to be_truthy
  end
  
  it "can be available 24 hours" do
    hours = build :operating_hours, start_time: "00:00", end_time: "00:00"
    expect(hours.valid?).to be_truthy
    expect(hours.is_24_hours?).to be_truthy
  end
  
  it "can make itself unavailable" do
    hours = build :operating_hours
    expect(hours.is_unavailable?).to be_falsey
    hours.make_unavailable
    expect(hours.is_unavailable?).to be_truthy
  end
  
  it "can make itself available 24 hours" do
    hours = build :operating_hours
    expect(hours.is_24_hours?).to be_falsey
    hours.make_24_hours
    expect(hours.is_24_hours?).to be_truthy
  end
end

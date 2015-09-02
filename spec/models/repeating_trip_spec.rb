require 'rails_helper'

RSpec.describe RepeatingTrip, type: :model do
  it_behaves_like "a recurring ride coordinator scheduler"
  
  it "requires pickup_time to be a valid date" do
    repeating_trip = build :repeating_trip, pickup_time: "2013-13-13", appointment_time: "2013-12-12"
    expect(repeating_trip.valid?).to be_falsey
    expect(repeating_trip.errors.keys).to include :pickup_time

    repeating_trip.pickup_time = "12/12/12"
    expect(repeating_trip.valid?).to be_truthy
  end
  
  it "requires appointment_time to be a valid date" do
    repeating_trip = build :repeating_trip, appointment_time: "13/13/13"
    expect(repeating_trip.valid?).to be_falsey
    expect(repeating_trip.errors.keys).to include :appointment_time

    repeating_trip.appointment_time = "12/12/12"
    expect(repeating_trip.valid?).to be_truthy
  end
  
  describe "#instantiate!" do
    it "generates trips"
  end
  
  it "if pickup_time is assigned a string that ends in 'a', it automatically appends an 'm' before parsing" do
    repeating_trip = build :repeating_trip
    time = "1976-05-09 01:00:00 a"
    repeating_trip.pickup_time = time
    expect(repeating_trip.pickup_time).not_to eq Time.zone.parse(time)
    expect(repeating_trip.pickup_time).to eq Time.zone.parse("#{time}m")
  end

  it "if appointment_time is assigned a string that ends in 'a', it automatically appends an 'm' before parsing" do
    repeating_trip = build :repeating_trip
    time = "1976-05-09 01:00:00 a"
    repeating_trip.appointment_time = time
    expect(repeating_trip.appointment_time).not_to eq Time.zone.parse(time)
    expect(repeating_trip.appointment_time).to eq Time.zone.parse("#{time}m")
  end
end

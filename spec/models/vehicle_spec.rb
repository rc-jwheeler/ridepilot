require "rails_helper"

RSpec.describe Vehicle, type: :model do
  it "requires a provider" do
    vehicle = build :vehicle, provider: nil
    expect(vehicle.valid?).to be_falsey
    expect(vehicle.errors.keys).to include :provider
  end
  
  it "requires a default_driver" do
    vehicle = build :vehicle, default_driver: nil
    expect(vehicle.valid?).to be_falsey
    expect(vehicle.errors.keys).to include :default_driver
  end
  
  it "requires a name" do
    vehicle = build :vehicle, name: nil
    expect(vehicle.valid?).to be_falsey
    expect(vehicle.errors.keys).to include :name
  end
  
  it "requires a properly formatted VIN, when present" do
    vehicle = build :vehicle, vin: nil
    expect(vehicle.valid?).to be_truthy
    
    # length: {is: 17}, format: {with: /\A[^ioq]*\z/i}    
    %w(x2345678901234567 y2345678901234567 z2345678901234567).each do |good_vin|
      vehicle.vin = good_vin
      expect(vehicle.valid?).to be_truthy
    end
    
    %w(z234567890123456 i2345678901234567 o2345678901234567 q2345678901234567).each do |bad_vin|
      vehicle.vin = bad_vin
      expect(vehicle.valid?).to be_falsey
      expect(vehicle.errors.keys).to include :vin
    end
  end
end

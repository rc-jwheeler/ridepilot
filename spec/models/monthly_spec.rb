require 'spec_helper'

describe Monthly do
  describe "provider_id" do
    it "should be an integer field" do
      m = Monthly.new
      m.should respond_to(:provider_id)
      m.provider_id = "1"
      m.provider_id.should eq 1
      m.provider_id = "0"
      m.provider_id.should eq 0
    end
  end

  describe "start_date" do
    it "should be a date field" do
      m = Monthly.new
      m.should respond_to(:start_date)
      m.start_date = "1"
      m.start_date.should be_nil
      m.start_date = "2013-06-01"
      m.start_date.should eq Date.new(2013, 6, 1)
    end
  end

  describe "volunteer_admin_hours" do
    it "should be an integer" do
      m = Monthly.new
      m.should respond_to(:volunteer_admin_hours)
      m.volunteer_admin_hours = "1"
      m.volunteer_admin_hours.should eq 1
      m.volunteer_admin_hours = "0"
      m.volunteer_admin_hours.should eq 0
    end
    
    it "should only allow integers greater than or equal to 0" do
      m = Monthly.new
      m.volunteer_admin_hours = -1
      m.valid?
      m.errors.keys.include?(:volunteer_admin_hours).should be_true
      m.errors[:volunteer_admin_hours].should include "must be greater than or equal to 0"
      
      m.volunteer_admin_hours = 0
      m.valid?
      m.errors.keys.include?(:volunteer_admin_hours).should_not be_true
    end
  end

  describe "volunteer_escort_hours" do
    it "should be an integer" do
      m = Monthly.new
      m.should respond_to(:volunteer_escort_hours)
      m.volunteer_escort_hours = "1"
      m.volunteer_escort_hours.should eq 1
      m.volunteer_escort_hours = "0"
      m.volunteer_escort_hours.should eq 0
    end
    
    it "should only allow integers greater than or equal to 0" do
      m = Monthly.new
      m.volunteer_escort_hours = -1
      m.valid?
      m.errors.keys.include?(:volunteer_escort_hours).should be_true
      m.errors[:volunteer_escort_hours].should include "must be greater than or equal to 0"
      
      m.volunteer_escort_hours = 0
      m.valid?
      m.errors.keys.include?(:volunteer_escort_hours).should_not be_true
    end
  end
  
  describe "uniqueness" do
    it "should validate uniqueness based on provider_id and start_date" do
      pending
    end
  end
end
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

  describe "funding_source_id" do
    it "should be an integer field" do
      m = Monthly.new
      m.should respond_to(:funding_source_id)
      m.funding_source_id = "1"
      m.funding_source_id.should eq 1
      m.funding_source_id = "0"
      m.funding_source_id.should eq 0
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
      m.errors.keys.include?(:volunteer_admin_hours).should be_truthy
      m.errors[:volunteer_admin_hours].should include "must be greater than or equal to 0"
      
      m.volunteer_admin_hours = 0
      m.valid?
      m.errors.keys.include?(:volunteer_admin_hours).should_not be_truthy
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
      m.errors.keys.include?(:volunteer_escort_hours).should be_truthy
      m.errors[:volunteer_escort_hours].should include "must be greater than or equal to 0"
      
      m.volunteer_escort_hours = 0
      m.valid?
      m.errors.keys.include?(:volunteer_escort_hours).should_not be_truthy
    end
  end
  
  describe "uniqueness" do
    before do
      @p1 = create :provider
      @p2 = create :provider
      
      @f1 = FundingSource.create(name: "FS1")
      @f2 = FundingSource.create(name: "FS2")
    end
    
    it "should validate start_date uniqueness based on provider_id and funding_source_id" do
      start_date = Date.today
      m1 = Monthly.new(start_date: start_date, provider: @p1, funding_source: @f1, volunteer_escort_hours: 0, volunteer_admin_hours: 0)
      m1.save.should be_truthy
      
      m2 = Monthly.new(start_date: start_date, provider: @p1, funding_source: @f1, volunteer_escort_hours: 0, volunteer_admin_hours: 0)
      m2.valid?.should be_falsey
      m2.errors.keys.should include(:start_date)
      m2.errors[:start_date].should include "has already been used for the given provider and funding source"
      
      m2.provider = @p2
      m2.funding_source = @f1
      m2.valid?.should be_truthy
      m2.errors.keys.should_not include(:start_date)
      
      m2.provider = @p1
      m2.funding_source = @f2
      m2.valid?.should be_truthy
      m2.errors.keys.should_not include(:start_date)
      
      m2.provider = @p1
      m2.funding_source = @f1
      m2.start_date = start_date + 1.day
      m2.valid?.should be_truthy
      m2.errors.keys.should_not include(:start_date)
      
      m2.save.should be_truthy
    end
  end
end
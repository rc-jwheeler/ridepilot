require 'spec_helper'

describe Provider do
  describe "reimbursement rates" do
    describe "oaa3b_per_ride_reimbursement_rate" do
      it "should be an integer field" do
        p = Provider.new
        p.should respond_to(:oaa3b_per_ride_reimbursement_rate)
        p.oaa3b_per_ride_reimbursement_rate = "1"
        p.oaa3b_per_ride_reimbursement_rate.should eq 1.0
        p.oaa3b_per_ride_reimbursement_rate = "0.12"
        p.oaa3b_per_ride_reimbursement_rate.should eq 0.12
      end
    
      it "should only allow values greater than 0" do
        p = Provider.new
        p.oaa3b_per_ride_reimbursement_rate = 0
        p.valid?
        p.errors.keys.include?(:oaa3b_per_ride_reimbursement_rate).should be_true
        p.errors[:oaa3b_per_ride_reimbursement_rate].should include "must be greater than 0"
      
        p.oaa3b_per_ride_reimbursement_rate = 1
        p.valid?
        p.errors.keys.include?(:oaa3b_per_ride_reimbursement_rate).should_not be_true
      end
    end

    describe "ride_connection_per_ride_reimbursement_rate" do
      it "should be an integer field" do
        p = Provider.new
        p.should respond_to(:ride_connection_per_ride_reimbursement_rate)
        p.ride_connection_per_ride_reimbursement_rate = "1"
        p.ride_connection_per_ride_reimbursement_rate.should eq 1.0
        p.ride_connection_per_ride_reimbursement_rate = "0.12"
        p.ride_connection_per_ride_reimbursement_rate.should eq 0.12
      end
    
      it "should only allow values greater than 0" do
        p = Provider.new
        p.ride_connection_per_ride_reimbursement_rate = 0
        p.valid?
        p.errors.keys.include?(:ride_connection_per_ride_reimbursement_rate).should be_true
        p.errors[:ride_connection_per_ride_reimbursement_rate].should include "must be greater than 0"
      
        p.ride_connection_per_ride_reimbursement_rate = 1
        p.valid?
        p.errors.keys.include?(:ride_connection_per_ride_reimbursement_rate).should_not be_true
      end
    end

    describe "trimet_per_ride_reimbursement_rate" do
      it "should be an integer field" do
        p = Provider.new
        p.should respond_to(:trimet_per_ride_reimbursement_rate)
        p.trimet_per_ride_reimbursement_rate = "1"
        p.trimet_per_ride_reimbursement_rate.should eq 1.0
        p.trimet_per_ride_reimbursement_rate = "0.12"
        p.trimet_per_ride_reimbursement_rate.should eq 0.12
      end
    
      it "should only allow values greater than 0" do
        p = Provider.new
        p.trimet_per_ride_reimbursement_rate = 0
        p.valid?
        p.errors.keys.include?(:trimet_per_ride_reimbursement_rate).should be_true
        p.errors[:trimet_per_ride_reimbursement_rate].should include "must be greater than 0"
      
        p.trimet_per_ride_reimbursement_rate = 1
        p.valid?
        p.errors.keys.include?(:trimet_per_ride_reimbursement_rate).should_not be_true
      end
    end

    describe "stf_van_per_ride_reimbursement_rate" do
      it "should be an integer field" do
        p = Provider.new
        p.should respond_to(:stf_van_per_ride_reimbursement_rate)
        p.stf_van_per_ride_reimbursement_rate = "1"
        p.stf_van_per_ride_reimbursement_rate.should eq 1.0
        p.stf_van_per_ride_reimbursement_rate = "0.12"
        p.stf_van_per_ride_reimbursement_rate.should eq 0.12
      end
    
      it "should only allow values greater than 0" do
        p = Provider.new
        p.stf_van_per_ride_reimbursement_rate = 0
        p.valid?
        p.errors.keys.include?(:stf_van_per_ride_reimbursement_rate).should be_true
        p.errors[:stf_van_per_ride_reimbursement_rate].should include "must be greater than 0"
      
        p.stf_van_per_ride_reimbursement_rate = 1
        p.valid?
        p.errors.keys.include?(:stf_van_per_ride_reimbursement_rate).should_not be_true
      end
    end

    describe "stf_taxi_per_ride_administrative_fee" do
      it "should be an integer field" do
        p = Provider.new
        p.should respond_to(:stf_taxi_per_ride_administrative_fee)
        p.stf_taxi_per_ride_administrative_fee = "1"
        p.stf_taxi_per_ride_administrative_fee.should eq 1.0
        p.stf_taxi_per_ride_administrative_fee = "0.12"
        p.stf_taxi_per_ride_administrative_fee.should eq 0.12
      end
    
      it "should only allow values greater than 0" do
        p = Provider.new
        p.stf_taxi_per_ride_administrative_fee = 0
        p.valid?
        p.errors.keys.include?(:stf_taxi_per_ride_administrative_fee).should be_true
        p.errors[:stf_taxi_per_ride_administrative_fee].should include "must be greater than 0"
      
        p.stf_taxi_per_ride_administrative_fee = 1
        p.valid?
        p.errors.keys.include?(:stf_taxi_per_ride_administrative_fee).should_not be_true
      end
    end

    describe "stf_taxi_per_ride_ambulatory_load_fee" do
      it "should be an integer field" do
        p = Provider.new
        p.should respond_to(:stf_taxi_per_ride_ambulatory_load_fee)
        p.stf_taxi_per_ride_ambulatory_load_fee = "1"
        p.stf_taxi_per_ride_ambulatory_load_fee.should eq 1.0
        p.stf_taxi_per_ride_ambulatory_load_fee = "0.12"
        p.stf_taxi_per_ride_ambulatory_load_fee.should eq 0.12
      end
    
      it "should only allow values greater than 0" do
        p = Provider.new
        p.stf_taxi_per_ride_ambulatory_load_fee = 0
        p.valid?
        p.errors.keys.include?(:stf_taxi_per_ride_ambulatory_load_fee).should be_true
        p.errors[:stf_taxi_per_ride_ambulatory_load_fee].should include "must be greater than 0"
      
        p.stf_taxi_per_ride_ambulatory_load_fee = 1
        p.valid?
        p.errors.keys.include?(:stf_taxi_per_ride_ambulatory_load_fee).should_not be_true
      end
    end

    describe "stf_taxi_per_ride_wheelchair_load_fee" do
      it "should be an integer field" do
        p = Provider.new
        p.should respond_to(:stf_taxi_per_ride_wheelchair_load_fee)
        p.stf_taxi_per_ride_wheelchair_load_fee = "1"
        p.stf_taxi_per_ride_wheelchair_load_fee.should eq 1.0
        p.stf_taxi_per_ride_wheelchair_load_fee = "0.12"
        p.stf_taxi_per_ride_wheelchair_load_fee.should eq 0.12
      end
    
      it "should only allow values greater than 0" do
        p = Provider.new
        p.stf_taxi_per_ride_wheelchair_load_fee = 0
        p.valid?
        p.errors.keys.include?(:stf_taxi_per_ride_wheelchair_load_fee).should be_true
        p.errors[:stf_taxi_per_ride_wheelchair_load_fee].should include "must be greater than 0"
      
        p.stf_taxi_per_ride_wheelchair_load_fee = 1
        p.valid?
        p.errors.keys.include?(:stf_taxi_per_ride_wheelchair_load_fee).should_not be_true
      end
    end

    describe "stf_taxi_per_mile_ambulatory_reimbursement_rate" do
      it "should be an integer field" do
        p = Provider.new
        p.should respond_to(:stf_taxi_per_mile_ambulatory_reimbursement_rate)
        p.stf_taxi_per_mile_ambulatory_reimbursement_rate = "1"
        p.stf_taxi_per_mile_ambulatory_reimbursement_rate.should eq 1.0
        p.stf_taxi_per_mile_ambulatory_reimbursement_rate = "0.12"
        p.stf_taxi_per_mile_ambulatory_reimbursement_rate.should eq 0.12
      end
    
      it "should only allow values greater than 0" do
        p = Provider.new
        p.stf_taxi_per_mile_ambulatory_reimbursement_rate = 0
        p.valid?
        p.errors.keys.include?(:stf_taxi_per_mile_ambulatory_reimbursement_rate).should be_true
        p.errors[:stf_taxi_per_mile_ambulatory_reimbursement_rate].should include "must be greater than 0"
      
        p.stf_taxi_per_mile_ambulatory_reimbursement_rate = 1
        p.valid?
        p.errors.keys.include?(:stf_taxi_per_mile_ambulatory_reimbursement_rate).should_not be_true
      end
    end

    describe "stf_taxi_per_mile_wheelchair_reimbursement_rate" do
      it "should be an integer field" do
        p = Provider.new
        p.should respond_to(:stf_taxi_per_mile_wheelchair_reimbursement_rate)
        p.stf_taxi_per_mile_wheelchair_reimbursement_rate = "1"
        p.stf_taxi_per_mile_wheelchair_reimbursement_rate.should eq 1.0
        p.stf_taxi_per_mile_wheelchair_reimbursement_rate = "0.12"
        p.stf_taxi_per_mile_wheelchair_reimbursement_rate.should eq 0.12
      end
    
      it "should only allow values greater than 0" do
        p = Provider.new
        p.stf_taxi_per_mile_wheelchair_reimbursement_rate = 0
        p.valid?
        p.errors.keys.include?(:stf_taxi_per_mile_wheelchair_reimbursement_rate).should be_true
        p.errors[:stf_taxi_per_mile_wheelchair_reimbursement_rate].should include "must be greater than 0"
      
        p.stf_taxi_per_mile_wheelchair_reimbursement_rate = 1
        p.valid?
        p.errors.keys.include?(:stf_taxi_per_mile_wheelchair_reimbursement_rate).should_not be_true
      end
    end
  end
end

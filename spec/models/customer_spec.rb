require "rails_helper"

describe Customer do
  describe "default_service_level" do
    it "should be a string field" do
      c = Customer.new
      c.should respond_to(:default_service_level)
      c.default_service_level = "abc"
      c.default_service_level.should == "abc"
    end
  end
  
  describe "default_funding_source_id" do
    it "should be an integer field" do
      c = Customer.new
      c.should respond_to(:default_funding_source_id)
      c.default_funding_source_id = "1"
      c.default_funding_source_id.should eq 1
      c.default_funding_source_id = "0"
      c.default_funding_source_id.should eq 0
    end
  end
  
  describe "ada_eligible" do
    it "should be a boolean field" do
      c = Customer.new
      c.should respond_to(:ada_eligible)
      c.ada_eligible = "1"
      c.ada_eligible.should be_truthy
      c.ada_eligible = "0"
      c.ada_eligible.should be_falsey
    end
  end
  
  describe "medicaid_eligible" do
    it "should be a boolean field" do
      c = Customer.new
      c.should respond_to(:medicaid_eligible)
      c.medicaid_eligible = "1"
      c.medicaid_eligible.should be_truthy
      c.medicaid_eligible = "0"
      c.medicaid_eligible.should be_falsey
    end
  end
  
  describe "prime_number" do
    it "should be a string field" do
      c = Customer.new
      c.should respond_to(:prime_number)
      c.prime_number = "abc"
      c.prime_number.should == "abc"
    end
  end
  
  describe "replace_with!" do
    context "when no customer id" do
      attr_reader :customer
      
      before do
        @customer = create :customer
      end
      
      it "is false" do
        @customer.replace_with!("").should_not be
      end
    end
    
    context "when invalid customer id" do
      attr_reader :customer
      
      before do
        @customer = create :customer
      end
      
      it "is false" do
        @customer.replace_with!(-1).should_not be
      end
    end
    
    context "when valid customer id" do
      context "when customer has trips" do
        attr_reader :customer, :trips, :other

        before do
          @customer = create :customer
          @trips    = (1..5).map { create :trip, :customer => customer }
          @other    = create :customer
          
          customer.replace_with!(other.id)
        end
        
        it "destroys self" do
          Customer.exists?(customer.id).should_not be
        end

        it "moves self's trips to other customer" do
          for trip in trips
            trip.reload.customer.should == other
          end
        end
      end
      
      context "when customer has no trips" do
        attr_reader :customer

        before do
          @customer = create :customer
        end
        
        it "destroys self" do

        end
      end
      
      context "when other_customer_id is the same as customer.id" do
        before do
          @customer = create :customer
          @other_customer = create :customer
        end
        
        it "should return false" do
          @customer.replace_with!(@customer.id).should be_falsey
          @customer.replace_with!(@other_customer.id).should_not be_falsey
        end
      end
    end
  end
end

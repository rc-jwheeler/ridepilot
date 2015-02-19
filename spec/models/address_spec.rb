require "rails_helper"

RSpec.describe Address do
  describe "replace_with!" do
    context "when no address id" do
      attr_reader :address
      
      before do
        @address = create :address
      end
      
      it "is false" do
        expect(@address.replace_with!("")).not_to be
      end
    end
    
    context "when invalid address id" do
      attr_reader :address
      
      before do
        @address = create :address
      end
      
      it "is false" do
        expect(@address.replace_with!(-1)).not_to be
      end
    end
    
    context "when valid address id" do
      context "when address has trips_from" do
        attr_reader :address, :trips, :other

        before do
          @address = create :address
          @trips    = (1..5).map { create :trip, :pickup_address => address }
          @other    = create :address
          
          address.replace_with!(other.id)
        end
        
        it "destroys self" do
          expect(Address.exists?(address.id)).not_to be
        end

        it "moves self's trips to other address" do
          for trip in trips
            expect(trip.reload.pickup_address).to eq(other)
          end
        end
      end
      
    end
    
    context "when valid address id" do
      context "when address has trips_to" do
        attr_reader :address, :trips, :other

        before do
          @address = create :address
          @trips    = (1..5).map { create :trip, :dropoff_address => address }
          @other    = create :address
          
          address.replace_with!(other.id)
        end
        
        it "destroys self" do
          expect(Address.exists?(address.id)).not_to be
        end

        it "moves self's trips to other address" do
          for trip in trips
            expect(trip.reload.dropoff_address).to eq(other)
          end
        end
      end
      
    end
    
  end
end

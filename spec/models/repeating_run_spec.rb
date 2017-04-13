require 'rails_helper'

RSpec.describe RepeatingRun, type: :model do
  it_behaves_like "a recurring ride coordinator scheduler"
    
  describe "#instantiate!" do
    # TODO Add some robust examples
    # Partially exercised by recurring_ride_coordinator_shared_examples.rb
    it "generates runs"
  end

  it_behaves_like "a recurring ride coordinator" do
    before do
      @scheduled_instance_class = Run 
      
      # To help us know what attribute to check occurrence dates against
      @occurrence_date_attribute = :date
    end
  end
end

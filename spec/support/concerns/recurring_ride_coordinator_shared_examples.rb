require 'spec_helper'

# For model specs
RSpec.shared_examples "a recurring ride coordinator" do
  before do
    @described_class_factory = described_class.name.underscore.to_sym
  end

  describe "DAYS_OF_WEEK" do
    it "contains a list of the days of the week" do
      expect(Trip::DAYS_OF_WEEK).to include "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"
    end
    
    it "defines a method that checks whether it repeats for each given day of the week" do
      trip = build :trip
      expect(trip).to respond_to :repeats_sundays
      expect(trip).to respond_to :repeats_sundays=
      expect(trip).to respond_to :repeats_mondays
      expect(trip).to respond_to :repeats_mondays=
      expect(trip).to respond_to :repeats_tuesdays
      expect(trip).to respond_to :repeats_tuesdays=
      expect(trip).to respond_to :repeats_wednesdays
      expect(trip).to respond_to :repeats_wednesdays=
      expect(trip).to respond_to :repeats_thursdays
      expect(trip).to respond_to :repeats_thursdays=
      expect(trip).to respond_to :repeats_fridays
      expect(trip).to respond_to :repeats_fridays=
      expect(trip).to respond_to :repeats_saturdays
      expect(trip).to respond_to :repeats_saturdays=
    end
  end  
end

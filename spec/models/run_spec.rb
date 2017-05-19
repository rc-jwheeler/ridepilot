require "rails_helper"

RSpec.describe Run, type: :model do

  describe "set_complete" do
    it "is called before validation" do
      run = build :run
      expect(run).to receive(:set_complete)
      run.valid?
    end

    it "checks for any pending trips" do
      run = create :run, start_odometer:100, end_odometer: 200
      trip = create :trip, run: run, trip_result: nil
      run.valid?
      expect(run.complete?).to be_falsey

      trip.update_attributes trip_result: create(:trip_result)
      run.valid?
      expect(run.complete?).to be_truthy
    end

    it "uses the Provider#fields_required_for_run_completion to decide if a run is considered complete" do
      run = create :run, start_odometer:100, end_odometer: 200
      run.provider.update_attributes fields_required_for_run_completion: %w(paid)
      run.valid?
      expect(run.complete?).to be_falsey

      run.paid = true
      run.valid?
      expect(run.complete?).to be_truthy
    end
  end
  
  describe 'name uniqueness validation' do
    
    # Set some context...
    let(:provider_a) { create(:provider) }
    let(:provider_b) { create(:provider) }
    before(:each) { create(:run, :tomorrow, name: "Run A", provider: provider_a) }
    before(:each) { create(:repeating_run, :tomorrow, name: "Run C", provider: provider_a) }
    
    it 'name must be unique among daily runs by date and provider' do
      valid_run_diff_name = build(:run, :tomorrow, name: "Run B", provider: provider_a)
      valid_run_diff_provider = build(:run, :tomorrow, name: "Run A", provider: provider_b)
      valid_run_diff_date = build(:run, :next_week, name: "Run A", provider: provider_a)
      invalid_run = build(:run, :tomorrow, name: "Run A", provider: provider_a)
      
      expect(valid_run_diff_name.valid?).to be true
      expect(valid_run_diff_provider.valid?).to be true
      expect(valid_run_diff_date.valid?).to be true
      expect(invalid_run.valid?).to be false
    end
    
    it 'name must be unique among repeating runs by date and provider' do
      valid_run_diff_name = build(:run, :tomorrow, name: "Run D", provider: provider_a)
      valid_run_diff_provider = build(:run, :tomorrow, name: "Run C", provider: provider_b)
      valid_run_diff_date = build(:run, :next_week, name: "Run C", provider: provider_a)
      invalid_run_this_week = build(:run, :tomorrow, name: "Run C", provider: provider_a)
      invalid_run_next_week = build(:run, date: Date.tomorrow + 1.week, name: "Run C", provider: provider_a)
            
      expect(valid_run_diff_name.valid?).to be true
      expect(valid_run_diff_provider.valid?).to be true
      expect(valid_run_diff_date.valid?).to be true
      expect(invalid_run_this_week.valid?).to be false
      expect(invalid_run_next_week.valid?).to be false
    end
    
  end
end

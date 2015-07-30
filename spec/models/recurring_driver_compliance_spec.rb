require 'rails_helper'

RSpec.describe RecurringDriverCompliance, type: :model do
  it "requires a provider" do
    recurrence = build :recurring_driver_compliance, provider: nil
    expect(recurrence.valid?).to be_falsey
    expect(recurrence.errors.keys).to include :provider
  end

  it "requires an event name" do
    recurrence = build :recurring_driver_compliance, event_name: nil
    expect(recurrence.valid?).to be_falsey
    expect(recurrence.errors.keys).to include :event_name
  end
  
  it "requires a recurrence schedule of either 'days', 'weeks', 'months', or 'years'" do
    recurrence = build :recurring_driver_compliance, recurrence_schedule: nil
    expect(recurrence.valid?).to be_falsey
    expect(recurrence.errors.keys).to include :recurrence_schedule
    
    recurrence.recurrence_schedule = "foo"
    expect(recurrence.valid?).to be_falsey
    expect(recurrence.errors.keys).to include :recurrence_schedule
    
    %w(days weeks months years).each do |schedule|
      recurrence.recurrence_schedule = schedule
      expect(recurrence.valid?).to be_truthy
    end
  end
  
  it "requires a numeric recurrence frequency greater than 0" do
    recurrence = build :recurring_driver_compliance, recurrence_frequency: nil
    expect(recurrence.valid?).to be_falsey
    expect(recurrence.errors.keys).to include :recurrence_frequency
    
    %w(foo -1 0).each do |frequency|
      recurrence.recurrence_frequency = frequency
      expect(recurrence.valid?).to be_falsey
      expect(recurrence.errors.keys).to include :recurrence_frequency
    end
    
    recurrence.recurrence_frequency = "1"
    expect(recurrence.valid?).to be_truthy
  end

  it "requires a valid start date on or after today" do
    recurrence = build :recurring_driver_compliance, start_date: nil
    expect(recurrence.valid?).to be_falsey
    expect(recurrence.errors.keys).to include :start_date

    recurrence.start_date = Date.current
    expect(recurrence.valid?).to be_truthy
  end
  
  it "requires a future start rule of either 'immediately', 'on_schedule' (i.e. based on start date), or 'time_span'" do
    recurrence = build :recurring_driver_compliance, future_start_rule: nil, future_start_schedule: 'days', future_start_frequency: 1
    expect(recurrence.valid?).to be_falsey
    expect(recurrence.errors.keys).to include :future_start_rule
    
    recurrence.future_start_rule = "foo"
    expect(recurrence.valid?).to be_falsey
    expect(recurrence.errors.keys).to include :future_start_rule
    
    %w(immediately on_schedule time_span).each do |rule|
      recurrence.future_start_rule = rule
      expect(recurrence.valid?).to be_truthy
    end
  end
  
  it "requires a future start schedule of either 'days', 'weeks', 'months', or 'years' when future start rule is 'time_span'" do
    recurrence = build :recurring_driver_compliance, future_start_rule: 'time_span', future_start_schedule: nil, future_start_frequency: 1
    expect(recurrence.valid?).to be_falsey
    expect(recurrence.errors.keys).to include :future_start_schedule
    
    recurrence.future_start_schedule = "foo"
    expect(recurrence.valid?).to be_falsey
    expect(recurrence.errors.keys).to include :future_start_schedule
    
    %w(days weeks months years).each do |schedule|
      recurrence.future_start_schedule = schedule
      expect(recurrence.valid?).to be_truthy
    end
  end
  
  it "requires a numeric future start frequency greater than 0 when future start rule is 'time_span'" do
    recurrence = build :recurring_driver_compliance, future_start_rule: 'time_span', future_start_schedule: 'days', future_start_frequency: nil
    expect(recurrence.valid?).to be_falsey
    expect(recurrence.errors.keys).to include :future_start_frequency
    
    %w(foo -1 0).each do |frequency|
      recurrence.future_start_frequency = frequency
      expect(recurrence.valid?).to be_falsey
      expect(recurrence.errors.keys).to include :future_start_frequency
    end
    
    recurrence.future_start_frequency = "1"
    expect(recurrence.valid?).to be_truthy
  end
  
  it "can prefer scheduling on compliance date over due date" do
    recurrence = build :recurring_driver_compliance, compliance_date_based_scheduling: nil
    expect(recurrence.valid?).to be_falsey
    expect(recurrence.errors.keys).to include :compliance_date_based_scheduling
    
    [true, false].each do |bool|
      recurrence.compliance_date_based_scheduling = bool.to_s
      expect(recurrence.valid?).to be_truthy
      expect(recurrence.compliance_date_based_scheduling?).to eq(bool)
    end
  end
  
  it "does not automatically generate child compliance events on creation (allowing for a period of time to modify the new event)" do
    expect {
      create :recurring_driver_compliance
    }.not_to change(DriverCompliance, :count)
  end
  
  describe "updating" do
    it "only allows the event name and event notes fields to be modified once it has spawned children" do
      recurrence = create :recurring_driver_compliance, event_name: "My Event", event_notes: nil
      create :driver_compliance, recurring_driver_compliance: recurrence

      recurrence.start_date = Date.tomorrow
      expect(recurrence.valid?).to be_falsey
      expect(recurrence.errors.keys).to include :start_date

      recurrence.reload
      recurrence.event_name = "My New Event"
      recurrence.event_notes = "My Notes"
      expect(recurrence.valid?).to be_truthy
    end
  
    it "pushes changes to event name and event notes fields to children" do
      recurrence = create :recurring_driver_compliance, event_name: "My Event", event_notes: nil
      driver_compliance = create :driver_compliance, recurring_driver_compliance: recurrence
      
      expect {
        recurrence.update_attributes event_name: "My Update Event Name", event_notes: "My Updated Event Notes"
      }.to change { [driver_compliance.reload.event, driver_compliance.reload.notes] }.to(["My Update Event Name", "My Updated Event Notes"])
    end
  end
  
  describe "destroying" do
    it "nullifies the association on children when destroyed, by default" do
      recurrence = create :recurring_driver_compliance, event_name: "My Event", event_notes: nil
      driver_compliance = create :driver_compliance, recurring_driver_compliance: recurrence
      
      expect {
        recurrence.destroy
      }.to change(RecurringDriverCompliance, :count).by(-1)
      expect(driver_compliance.reload.recurring_driver_compliance).to be_nil
    end
  
    it "can optionally delete incomplete children when destroyed, but will still nullify complete children" do
      recurrence = create :recurring_driver_compliance, event_name: "My Event", event_notes: nil
      driver_compliance_1 = create :driver_compliance, compliance_date: Date.current, recurring_driver_compliance: recurrence
      driver_compliance_2 = create :driver_compliance, recurring_driver_compliance: recurrence
      driver_compliance_3 = create :driver_compliance, :recurring
      
      expect {
        recurrence.destroy_with_incomplete_children!
      }.to change(RecurringDriverCompliance, :count).by(-1)
      expect(driver_compliance_1.reload.recurring_driver_compliance).to be_nil
      expect(DriverCompliance.all).to include driver_compliance_1
      expect(DriverCompliance.all).not_to include driver_compliance_2
      expect(DriverCompliance.all).to include driver_compliance_3
    end
  end
  
  describe "event generation" do
    it "only generates child compliance events for drivers of its own provider"
  
    it "sets the name and notes of children to the event name and event notes field, respectively"

    it "schedules new events on schedule based on the due date for 6 months out when due date scheduling is preferred"
  
    it "schedules 1 new event on schedule based on the compliance date only after the previous event is complete when compliance date scheduling is preferred"
  
    it "knows how to apply events to drivers created after it was defined"
  
    it "can calculate the first event date based on the start schedule for a given driver"

    it "can calculate the next event date based on the recurrence schedule for a given driver"
  end
end

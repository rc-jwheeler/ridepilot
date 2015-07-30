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
    recurrence = build :recurring_driver_compliance, future_start_rule: nil
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
  
  it "schedules new events on schedule based on the due date for 6 months out when due date scheduling is preferred"
  
  it "schedules 1 new event on schedule based on the compliance date only after the previous event is complete when compliance date scheduling is preferred"
  
  it "does not automatically generate child compliance events on creation (allowing for a period of time to modify the new event)" do
    expect {
      create :recurring_driver_compliance
    }.not_to change(DriverCompliance, :count)
  end

  it "only generates child compliance events for drivers of its own provider"
  
  it "knows how to apply events to drivers created after it was defined"
  
  it "does not allow scheduling attributes to be modified once it has generated children"
  
  it "pushes changes to event name and event notes fields to children"
  
  it "nullifies the association on children when destroyed, by default"
  
  it "can optionally delete incomplete children when destroyed, but will still nullify complete children"

  it "can rollback all changes (including its own deletion) when an error occurs while deleting with the optional flag to delete incomplete children"

  it "can calculate the first event date based on the start schedule for a given driver"

  it "can calculate the next event date based on the recurrence schedule for a given driver"
end

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
    before do
      # Freeze the date at Monday, June 1, 2015 at 12:00 PM
      Timecop.freeze(Chronic.parse("June 1, 2015"))

      # Start date is June 2, 2015
      @recurrence = create :recurring_driver_compliance,
        event_name: "Submit expenses",
        event_notes: "Don't forget!",
        recurrence_frequency: 3,
        recurrence_schedule: "months",
        start_date: Date.current.tomorrow,
        future_start_rule: "immediately",
        compliance_date_based_scheduling: false
      @provider = @recurrence.provider
    end

    describe "for drivers that already exist when the recurrence is created" do
      before do
        @driver = create :driver, provider: @provider
      end
      
      it "generates child compliance events for drivers of providers with recurrences defined" do
        expect {
          RecurringDriverCompliance.generate!
        }.to change { @driver.driver_compliances.count }
      end
      
      it "doesn't generates child compliance events for drivers of providers without recurrences defined" do
        driver_2 = create(:driver)
        expect {
          RecurringDriverCompliance.generate!
        }.not_to change { driver_2.driver_compliances.count }
      end

      it "sets the name and notes of generated children to the recurrence's event name and event notes fields, respectively" do
        RecurringDriverCompliance.generate!
        expect(@driver.driver_compliances.first.event).to eq "Submit expenses"
        expect(@driver.driver_compliances.first.notes).to eq "Don't forget!"
      end

      pending "is idempotent" do
        RecurringDriverCompliance.generate!
        
        expect {
          RecurringDriverCompliance.generate!
        }.not_to change(DriverCompliance, :count)
      end

      describe "without prior event occurrences" do
        describe "when due date scheduling is preferred" do
          it "schedules the first event on the start date" do
            RecurringDriverCompliance.generate!
            expect(@driver.driver_compliances.first.due_date).to eq Date.current.tomorrow
          end

          it "schedules more events on a schedule based on the start date, up to 6 months out"

          it "schedules only 1 event at a time when the recurrence schedule is more than 6 months"
        end

        describe "when compliance date scheduling is preferred" do
          it "schedules new events on a schedule based on the due date (because no previously occurrence exists to have been completed)"
        end
      end

      describe "with prior event occurrences" do
        describe "when due date scheduling is preferred" do
          it "schedules new events on a schedule based on the due date"
        end

        describe "when compliance date scheduling is preferred" do
          it "schedules 1 new event at a time on schedule based on the compliance date, but only after the previous event is complete"
        end
      end
    end

    describe "for drivers created after the recurrence is created" do
      describe "when it is still before the recurrence start date" do
        describe "with a future start rule of 'immediately" do
          pending "add tests"
        end

        describe "with a future start rule of 'on_schedule" do
          pending "add tests"
        end

        describe "with a future start rule of 'time_span" do
          pending "add tests"
        end
      end
      
      describe "when it is after the recurrence start date" do
        describe "with a future start rule of 'immediately" do
          pending "add tests"
        end

        describe "with a future start rule of 'on_schedule" do
          pending "add tests"
        end

        describe "with a future start rule of 'time_span" do
          pending "add tests"
        end
      end
    end
  end
end

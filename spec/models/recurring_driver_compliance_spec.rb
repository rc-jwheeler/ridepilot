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
  
  describe "calculating occurrence dates" do
    before do
      # This doesn't require a full model, so a double can stand in
      @dbl = instance_double "RecurringDriverCompliance", start_date: Date.current, recurrence_frequency: 1, recurrence_schedule: "months"
    end
    
    it "requires an RecurringDriverCompliance occurrence" do
      expect {
        RecurringDriverCompliance.calculate_occurrence_dates
      }.to raise_error(ArgumentError, /missing keyword/)

      expect {
        RecurringDriverCompliance.calculate_occurrence_dates recurrence: @dbl
      }.not_to raise_error
    end

    it "uses the occurrence start_date as the first_date by default" do
      expect(RecurringDriverCompliance.calculate_occurrence_dates(recurrence: @dbl).first).to eq Date.current
    end

    it "can accept an option first_date" do
      expect(RecurringDriverCompliance.calculate_occurrence_dates(recurrence: @dbl, first_date: Date.current.tomorrow).first).to eq Date.current.tomorrow
    end

    it "calculates 6 months worth of events by default" do
      expect(RecurringDriverCompliance.calculate_occurrence_dates(recurrence: @dbl).last).to eq Date.current + 6.months
    end
    
    it "can accept an optional end_date" do
      expect(RecurringDriverCompliance.calculate_occurrence_dates(recurrence: @dbl, end_date: Date.current + 2.months).last).to eq Date.current + 2.months
    end
    
    describe "irregular traversals" do
      it "handles monthly recurrences when the first_date is on the 31st" do
        Timecop.freeze(Date.parse("2015-01-31")) do
          # Jan 31 + 1 month is Feb 28, and Feb 28 + 1 month = Mar 28
          # But Jan 31 + 2 month = Mar 31
          dbl = instance_double "RecurringDriverCompliance", start_date: Date.current, recurrence_frequency: 1, recurrence_schedule: "months"
          expect(RecurringDriverCompliance.calculate_occurrence_dates recurrence: dbl, end_date: Date.parse("2015-12-31")).to eq [
            Date.parse("2015-01-31"),
            Date.parse("2015-02-28"),
            Date.parse("2015-03-31"),
            Date.parse("2015-04-30"),
            Date.parse("2015-05-31"),
            Date.parse("2015-06-30"),
            Date.parse("2015-07-31"),
            Date.parse("2015-08-31"),
            Date.parse("2015-09-30"),
            Date.parse("2015-10-31"),
            Date.parse("2015-11-30"),
            Date.parse("2015-12-31"),
          ]
        end
      end
      
      # Add other examples as edge-cases are discovered
    end
  end

  describe "event generation" do
    before do
      # Time.now is now frozen at Monday, June 1, 2015 at 12:00 PM
      Timecop.freeze(Chronic.parse("June 1, 2015"))
      
      # Start date is Tuesday, June 2, 2015
      @recurrence = create :recurring_driver_compliance,
        event_name: "Submit timesheet",
        event_notes: "Don't forget!",
        recurrence_frequency: 2,
        recurrence_schedule: "weeks",
        start_date: Date.parse("2015-06-02"),
        future_start_rule: "immediately",
        compliance_date_based_scheduling: false
      @provider = @recurrence.provider
    end
    
    after do
      Timecop.return
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
        expect(@driver.driver_compliances.first.event).to eq "Submit timesheet"
        expect(@driver.driver_compliances.first.notes).to eq "Don't forget!"
      end

      it "is idempotent" do
        RecurringDriverCompliance.generate!
        
        expect {
          RecurringDriverCompliance.generate!
        }.not_to change(DriverCompliance, :count)
      end

      describe "without prior event occurrences" do
        describe "when due date scheduling is preferred" do
          it "schedules new events on a schedule based on the start date, up to 6 months out" do
            # Time is still frozen at Monday, June 1, 2015 at 12:00 PM
            # Starting from Tue, Jun 2, 2015, bi-weekly occurrences over 
            # the next 6 months should include:
            expected_dates = [
              "2015-06-02",
              "2015-06-16",
              "2015-06-30",
              "2015-07-14",
              "2015-07-28",
              "2015-08-11",
              "2015-08-25",
              "2015-09-08",
              "2015-09-22",
              "2015-10-06",
              "2015-10-20",
              "2015-11-03",
              "2015-11-17",
              "2015-12-01"
            ]
            
            expect {
              RecurringDriverCompliance.generate!
            }.to change(DriverCompliance, :count).by(expected_dates.size)
            
            expected_dates.each do |expected_date|
              expect(@recurrence.driver_compliances.for(@driver).where(due_date: expected_date)).to exist
            end
          end

          it "won't schedule anything when the start_date is more than 6 months away" do
            @recurrence.update_attributes start_date: 7.months.from_now
            expect {
              RecurringDriverCompliance.generate!
            }.not_to change(DriverCompliance, :count)
          end

          it "will only schedule one event when the recurrence frequency is is greater than 6 months" do
            @recurrence.update_attributes recurrence_frequency: 7, recurrence_schedule: "months"
            expect {
              RecurringDriverCompliance.generate!
            }.to change(DriverCompliance, :count).by(1)
          end

          it "will only schedule one event when the start_date means the second occurrence will fall outside of 6 months" do
            @recurrence.update_attributes start_date: 3.months.from_now, recurrence_frequency: 4, recurrence_schedule: "months"
            expect {
              RecurringDriverCompliance.generate!
            }.to change(DriverCompliance, :count).by(1)
          end
        end

        describe "when compliance date scheduling is preferred" do
          it "schedules only the first event (because no previous occurrences exists that could be completed)"
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

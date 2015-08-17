require 'rails_helper'

RSpec.describe RecurringDriverCompliance, type: :model do
  it_behaves_like "a recurring compliance event scheduler" do
    before do
      @occurrence_owner_class = Driver
      @occurrence_class = DriverCompliance
      @occurrence_association = :driver_compliances
    end
  end

  it "requires a recurrence_schedule" do
    recurrence = build :recurring_driver_compliance, recurrence_schedule: nil
    expect(recurrence.valid?).to be_falsey
    expect(recurrence.errors.keys).to include :recurrence_schedule
  end

  it "requires a numeric recurrence_frequency" do
    recurrence = build :recurring_driver_compliance, recurrence_frequency: nil
    expect(recurrence.valid?).to be_falsey
    expect(recurrence.errors.keys).to include :recurrence_frequency
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

  describe ".adjusted_start_date" do
    describe "when as_of is before the recurrence start_date" do
      before do
        # as_of defaults to the current date
        @recurrence = create :recurring_driver_compliance,
          start_date: Date.current.tomorrow,
          recurrence_frequency: 1,
          recurrence_schedule: "months"
      end

      describe "with a future_start_rule of 'immediately'" do
        it "should return the start_date" do
          expect(described_class.adjusted_start_date @recurrence).to eq @recurrence.start_date
        end
      end

      describe "with a future_start_rule of 'on_schedule'" do
        before do
          @recurrence.update_columns future_start_rule: "on_schedule"
        end

        it "should return the start_date" do
          expect(described_class.adjusted_start_date @recurrence).to eq @recurrence.start_date
        end
      end

      describe "with a future_start_rule of 'time_span'" do
        before do
          @recurrence.update_columns future_start_rule: "time_span", future_start_schedule: "days", future_start_frequency: 10
        end

        it "should return the start_date" do
          expect(described_class.adjusted_start_date @recurrence).to eq @recurrence.start_date
        end
      end
    end

    describe "when as_of is after the recurrence start_date" do
      before do
        # Time.now is now frozen at Monday, June 1, 2015
        Timecop.freeze(Date.parse("2015-06-01"))

        @recurrence = create :recurring_driver_compliance,
          start_date: Date.current,
          recurrence_frequency: 1,
          recurrence_schedule: "months"
      end

      after do
        Timecop.return
      end

      describe "with a future_start_rule of 'immediately'" do
        it "should return the as_of date" do
          expect(described_class.adjusted_start_date @recurrence, as_of: Date.current.tomorrow).to eq Date.current.tomorrow
        end
      end

      describe "with a future_start_rule of 'on_schedule'" do
        before do
          @recurrence.update_columns future_start_rule: "on_schedule"
        end

        it "should return the next date of the occurrence on or after as_of, according to the recurrence schedule" do
          expect(described_class.adjusted_start_date @recurrence, as_of: Date.current.tomorrow).to eq Date.parse("2015-07-01")
        end
      end

      describe "with a future_start_rule of 'time_span'" do
        before do
          @recurrence.update_columns future_start_rule: "time_span", future_start_schedule: "days", future_start_frequency: 10
        end

        it "should return the next date of the occurrence starting after the time span from as_of" do
          expect(described_class.adjusted_start_date @recurrence, as_of: Date.parse("2015-06-15")).to eq Date.parse("2015-06-25")
        end
      end
    end
  end

  describe ".occurrence_dates_on_schedule_in_range" do
    before do
      # Time.now is now frozen at Thursday, January 1, 2015
      Timecop.freeze(Date.parse("2015-01-01"))

      @recurrence = create :recurring_driver_compliance,
        start_date: Date.current,
        recurrence_frequency: 1,
        recurrence_schedule: "months"
    end

    after do
      Timecop.return
    end

    it "uses the recurrence start_date to calculate the first occurrence by default" do
      expect(RecurringDriverCompliance.occurrence_dates_on_schedule_in_range(@recurrence).first).to eq @recurrence.start_date
    end

    it "accepts an optional first_date to calculate the first occurrence" do
      expect(RecurringDriverCompliance.occurrence_dates_on_schedule_in_range(@recurrence, first_date: @recurrence.start_date.tomorrow).first).to eq @recurrence.start_date.tomorrow
    end

    it "calculates dates within a 6 month window by default" do
      expect(RecurringDriverCompliance.occurrence_dates_on_schedule_in_range(@recurrence).last).to eq Date.parse("2015-06-01")
    end

    it "can accept an optional range_first_date" do
      expect(RecurringDriverCompliance.occurrence_dates_on_schedule_in_range(@recurrence, range_start_date: Date.current.tomorrow).first).to eq Date.parse("2015-02-01")
    end

    it "can accept an optional range_end_date" do
      expect(RecurringDriverCompliance.occurrence_dates_on_schedule_in_range(@recurrence, range_end_date: Date.current.tomorrow).last).to eq Date.parse("2015-01-01")
    end

    it "setting a range_first_date influences the default range_end_date" do
      expect(RecurringDriverCompliance.occurrence_dates_on_schedule_in_range(@recurrence, range_start_date: Date.parse("2015-07-01")).last).to eq Date.parse("2015-12-01")
    end

    # Add examples as edge-cases are discovered
    describe "irregular traversals" do
      # Jan 31 + 1.month is Feb 28, and Feb 28 + 1.month = Mar 28
      # But Jan 31 + 2.months = Mar 31
      describe "handles monthly recurrences when the first_date is on the 31st" do
        before do
          @recurrence = create :recurring_driver_compliance,
            start_date: Date.parse("2015-01-31"),
            recurrence_frequency: 1,
            recurrence_schedule: "months"
        end

        it "properly finds the last day of each subsequent month, even when the range_start_date is far into the future" do
          expect(RecurringDriverCompliance.occurrence_dates_on_schedule_in_range @recurrence, range_start_date: Date.parse("2023-09-15"), range_end_date: Date.parse("2024-09-14")).to eq [
            Date.parse("2023-09-30"),
            Date.parse("2023-10-31"),
            Date.parse("2023-11-30"),
            Date.parse("2023-12-31"),
            Date.parse("2024-01-31"),
            Date.parse("2024-02-29"),
            Date.parse("2024-03-31"),
            Date.parse("2024-04-30"),
            Date.parse("2024-05-31"),
            Date.parse("2024-06-30"),
            Date.parse("2024-07-31"),
            Date.parse("2024-08-31"),
          ]
        end
      end
    end
  end

  describe ".next_occurrence_date_from_previous_date_in_range" do
    before do
      # Time.now is now frozen at Thursday, January 1, 2015
      Timecop.freeze(Date.parse("2015-01-01"))

      @recurrence = create :recurring_driver_compliance,
        start_date: Date.current,
        recurrence_frequency: 1,
        recurrence_schedule: "months",
        compliance_date_based_scheduling: true
    end

    it "returns the next occurrence date from previous_date" do
      expect(RecurringDriverCompliance.next_occurrence_date_from_previous_date_in_range @recurrence, Date.parse("2015-01-01")).to eq Date.parse("2015-02-01")
    end

    it "calculates dates within a 6 month window by default" do
      @recurrence.update_columns recurrence_schedule: "years"
      expect(RecurringDriverCompliance.next_occurrence_date_from_previous_date_in_range @recurrence, Date.parse("2015-01-01")).to be_nil
    end

    it "can accept an optional range_end_date" do
      @recurrence.update_columns recurrence_schedule: "years"
      expect(RecurringDriverCompliance.next_occurrence_date_from_previous_date_in_range @recurrence, Date.parse("2015-01-01"), range_end_date: Date.parse("2016-01-01")).to eq Date.parse("2016-01-01")
    end

    it "doesn't care if we're super far into the future" do
      Timecop.freeze(Date.parse("2099-01-01")) do
        expect(RecurringDriverCompliance.next_occurrence_date_from_previous_date_in_range @recurrence, Date.parse("2015-01-01")).to eq Date.parse("2015-02-01")
        expect(RecurringDriverCompliance.next_occurrence_date_from_previous_date_in_range @recurrence, Date.current).to eq Date.parse("2099-02-01")
      end
    end

    # Add examples as edge-cases are discovered
    describe "irregular traversals" do
      # Jan 31 + 1.month is Feb 28, and Feb 28 + 1.month = Mar 28
      # But Jan 31 + 2.months = Mar 31
      # However we're only dealing with one unit at a time, so we don't care
      describe "handles monthly recurrences when the first_date is on the 31st" do
        before do
          @recurrence = create :recurring_driver_compliance,
            start_date: Date.parse("2015-01-31"),
            recurrence_frequency: 1,
            recurrence_schedule: "months",
            compliance_date_based_scheduling: true
        end

        it "ignores irregular monthly traversals, because the next due date is based solely off of the previous compliance date" do
          expect(RecurringDriverCompliance.next_occurrence_date_from_previous_date_in_range @recurrence, Date.parse("2015-01-31")).to eq Date.parse("2015-02-28")
          expect(RecurringDriverCompliance.next_occurrence_date_from_previous_date_in_range @recurrence, Date.parse("2015-02-28")).to eq Date.parse("2015-03-28")
          expect(RecurringDriverCompliance.next_occurrence_date_from_previous_date_in_range @recurrence, Date.parse("2015-03-31")).to eq Date.parse("2015-04-30")
        end
      end
    end
  end

  describe ".generate!" do
    before do
      # Time.now is now frozen at Monday, June 1, 2015
      Timecop.freeze(Date.parse("2015-06-01"))

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

    # Due date based scheduling is used when a compliance must be completed on
    # a regular schedule, regardless of when the previous occurrences were
    # completed.
    describe "when due date scheduling is preferred" do
      describe "for drivers that already exist when the recurrence is created" do
        before do
          @driver = create :driver, provider: @provider
        end

        describe "without prior event occurrences" do
          it "schedules new events on a schedule based on the start_date, up to 6 months out" do
            # Time is still frozen at Monday, June 1, 2015
            # Starting from Tue, Jun 2, 2015, bi-weekly occurrences over
            # the next 6 months should include:
            expected_dates = [
              "2015-06-02", "2015-06-16", "2015-06-30",
              "2015-07-14", "2015-07-28",
              "2015-08-11", "2015-08-25",
              "2015-09-08", "2015-09-22",
              "2015-10-06", "2015-10-20",
              "2015-11-03", "2015-11-17"
            ]

            expect {
              RecurringDriverCompliance.generate!
            }.to change(DriverCompliance, :count).by(13)

            expected_dates.each do |expected_date|
              expect(@recurrence.driver_compliances.for_driver(@driver).where(due_date: expected_date)).to exist
            end
          end

          it "won't schedule anything when the start_date is more than 6 months away" do
            @recurrence.update_columns start_date: 7.months.from_now
            expect {
              RecurringDriverCompliance.generate!
            }.not_to change(DriverCompliance, :count)
          end

          it "will only schedule one event when the recurrence frequency is is greater than 6 months" do
            @recurrence.update_columns recurrence_frequency: 7, recurrence_schedule: "months"
            expect {
              RecurringDriverCompliance.generate!
            }.to change(DriverCompliance, :count).by(1)
          end

          it "will only schedule one event when the start_date means the second occurrence will fall outside of 6 months" do
            @recurrence.update_columns start_date: 3.months.from_now, recurrence_frequency: 4, recurrence_schedule: "months"
            expect {
              RecurringDriverCompliance.generate!
            }.to change(DriverCompliance, :count).by(1)
          end
        end

        describe "with prior event occurrences" do
          before do
            # Time is still frozen at Monday, June 1, 2015
            # Creates 13 bi-weekly occurrences due from 2015-06-02 to 2015-11-17
            RecurringDriverCompliance.generate!
          end

          it "schedules new events on a schedule based on the due date" do
            # Travel 1 week into the future, to June 8, 2015
            Timecop.freeze(Date.parse("2015-06-08")) do
              expect {
                RecurringDriverCompliance.generate!
              }.to change(DriverCompliance, :count).by(1)

              # It should add 1 new bi-monthly occurrences due on 2015-12-01
              expect(@driver.driver_compliances.last.due_date).to eq Date.parse("2015-12-01")
            end
          end
        end
      end

      describe "for drivers created after the recurrence is created" do
        before do
          # Time is still frozen at Monday, June 1, 2015
          # Creates 13 bi-weekly occurrences due from 2015-06-02 to 2015-11-17
          RecurringDriverCompliance.generate!
        end

        describe "when it is still before the recurrence start_date" do
          before do
            # Time is still frozen at Monday, June 1, 2015
            @driver = create :driver, provider: @provider
          end
    
          describe "with a future_start_rule of 'immediately'" do
            it "should generate new events on schedule, starting with the recurrence start_date" do
              expect {
                RecurringDriverCompliance.generate!
              }.to change(DriverCompliance, :count).by(13)

              expect(@driver.driver_compliances.first.due_date).to eq @recurrence.start_date
              expect(@driver.driver_compliances.last.due_date).to eq Date.parse("2015-11-17")
            end
          end

          describe "with a future_start_rule of 'on_schedule'" do
            before do
              @recurrence.update_columns future_start_rule: "on_schedule"
            end
      
            it "should generate new events on schedule, starting with the recurrence start_date" do
              expect {
                RecurringDriverCompliance.generate!
              }.to change(DriverCompliance, :count).by(13)

              expect(@driver.driver_compliances.first.due_date).to eq @recurrence.start_date
              expect(@driver.driver_compliances.last.due_date).to eq Date.parse("2015-11-17")
            end
          end

          describe "with a future_start_rule of 'time_span'" do
            before do
              @recurrence.update_columns future_start_rule: "time_span", future_start_schedule: "days", future_start_frequency: 10
            end
      
            it "should generate new events on schedule, starting with the recurrence start_date" do
              expect {
                RecurringDriverCompliance.generate!
              }.to change(DriverCompliance, :count).by(13)

              expect(@driver.driver_compliances.first.due_date).to eq @recurrence.start_date
              expect(@driver.driver_compliances.last.due_date).to eq Date.parse("2015-11-17")
            end
          end
        end

        describe "when it is after the recurrence start_date" do
          before do
            # Travel 1 week into the future, to June 8, 2015
            Timecop.freeze(Date.parse("2015-06-08"))

            @driver = create :driver, provider: @provider
          end
    
          after do
            Timecop.return
          end
    
          describe "with a future_start_rule of 'immediately'" do
            it "should generate new events on schedule, starting immediately" do
              expect {
                RecurringDriverCompliance.generate!
              }.to change(DriverCompliance, :count).by(14)

              expect(@driver.driver_compliances.first.due_date).to eq Date.parse("2015-06-08")
              expect(@driver.driver_compliances.last.due_date).to eq Date.parse("2015-12-07")
            end
          end

          describe "with a future_start_rule of 'on_schedule'" do
            before do
              @recurrence.update_columns future_start_rule: "on_schedule"
            end
      
            it "should generate new events on schedule, starting with the next occurrence from today" do            
              expect {
                RecurringDriverCompliance.generate!
              }.to change(DriverCompliance, :count).by(13)

              expect(@driver.driver_compliances.first.due_date).to eq Date.parse("2015-06-16")
              expect(@driver.driver_compliances.last.due_date).to eq Date.parse("2015-12-01")
            end
          end

          describe "with a future_start_rule of 'time_span'" do
            before do
              @recurrence.update_columns future_start_rule: "time_span", future_start_schedule: "days", future_start_frequency: 10
            end
      
            it "should generate new events on schedule, with the first occurrence starting after the time span from today" do
              expect {
                RecurringDriverCompliance.generate!
              }.to change(DriverCompliance, :count).by(13)

              expect(@driver.driver_compliances.first.due_date).to eq Date.parse("2015-06-18")
              expect(@driver.driver_compliances.last.due_date).to eq Date.parse("2015-12-03")
            end
          end
        end
      end
    end

    # Compliance date based scheduling is used when a compliance is good for a
    # specific period of time. An example would be CPR certification, where the
    # certificate is only good for 1 year after the last time you completed
    # certification. For instance, if you completed certification on June 1,
    # 2015 it would be Good until May 30, 2016. If you then completed the
    # recertification on May 15, 2016, your new certificate would be good until
    # May 14, 2017.
    describe "when compliance date scheduling is preferred" do
      before do
        @recurrence.update_columns compliance_date_based_scheduling: true
      end

      describe "for drivers that already exist when the recurrence is created" do
        before do
          @driver = create :driver, provider: @provider
        end

        describe "without prior event occurrences" do
          it "schedules only one event on the start_date (no previous occurrences exists that could be completed)" do
            expect {
              RecurringDriverCompliance.generate!
            }.to change(DriverCompliance, :count).by(1)

            expect(DriverCompliance.last.due_date).to eq @recurrence.start_date
          end
        end

        describe "with prior event occurrences" do
          before do
            # Time is still frozen at Monday, June 1, 2015
            # Creates 1 occurrence due on 2015-06-02
            RecurringDriverCompliance.generate!
          end

          describe "when the previous occurrence is still incomplete" do
            it "schedules no new events" do
              # Travel 2 weeks into the future, to June 15, 2015
              Timecop.freeze(2.weeks.from_now) do
                expect {
                  RecurringDriverCompliance.generate!
                }.not_to change(DriverCompliance, :count)
              end
            end
          end

          describe "when the previous occurrence is complete" do
            before do
              # Time is still frozen at Monday, June 1, 2015
              @driver.driver_compliances.last.update_columns compliance_date: Date.current
            end

            it "schedules 1 new event" do
              # Travel 2 weeks into the future, to June 15, 2015
              Timecop.freeze(2.weeks.from_now) do
                expect {
                  RecurringDriverCompliance.generate!
                }.to change(DriverCompliance, :count).by(1)

                # Last occurrence was due 2015-06-02, completed 2015-06-01
                # It should add 1 new occurrence due on 2015-06-15
                expect(@driver.driver_compliances.last.due_date).to eq Date.parse("2015-06-15")
              end
            end
          end
        end
      end

      describe "for drivers created after the recurrence is created" do
        before do
          # Time is still frozen at Monday, June 1, 2015
          # Creates 13 bi-weekly occurrences due from 2015-06-02 to 2015-11-17
          RecurringDriverCompliance.generate!
        end

        describe "when it is still before the recurrence start_date" do
          before do
            # Time is still frozen at Monday, June 1, 2015
            @driver = create :driver, provider: @provider
          end
    
          describe "with a future_start_rule of 'immediately'" do
            it "should generate the 1st event on the recurrence start_date" do
              expect {
                RecurringDriverCompliance.generate!
              }.to change(DriverCompliance, :count).by(1)

              expect(DriverCompliance.last.due_date).to eq @recurrence.start_date
            end
          end

          describe "with a future_start_rule of 'on_schedule'" do
            before do
              @recurrence.update_columns future_start_rule: "on_schedule"
            end
      
            it "should generate the 1st event on the recurrence start_date" do
              expect {
                RecurringDriverCompliance.generate!
              }.to change(DriverCompliance, :count).by(1)

              expect(DriverCompliance.last.due_date).to eq @recurrence.start_date
            end
          end

          describe "with a future_start_rule of 'time_span'" do
            before do
              @recurrence.update_columns future_start_rule: "time_span", future_start_schedule: "days", future_start_frequency: 10
            end
      
            it "should generate the 1st event on the recurrence start_date" do
              expect {
                RecurringDriverCompliance.generate!
              }.to change(DriverCompliance, :count).by(1)

              expect(DriverCompliance.last.due_date).to eq @recurrence.start_date
            end
          end
        end

        describe "when it is after the recurrence start_date" do
          before do
            # Travel 1 week into the future, to June 8, 2015
            Timecop.freeze(Date.parse("2015-06-08"))

            @driver = create :driver, provider: @provider
          end
    
          after do
            Timecop.return
          end
    
          describe "with a future_start_rule of 'immediately'" do
            it "should generate one new event, starting immediately" do
              expect {
                RecurringDriverCompliance.generate!
              }.to change(DriverCompliance, :count).by(1)

              expect(@driver.driver_compliances.last.due_date).to eq Date.parse("2015-06-08")
            end
          end

          describe "with a future_start_rule of 'on_schedule'" do
            before do
              @recurrence.update_columns future_start_rule: "on_schedule"
            end
      
            it "should generate one new event, starting with the next occurrence from today" do
              expect {
                RecurringDriverCompliance.generate!
              }.to change(DriverCompliance, :count).by(1)

              expect(@driver.driver_compliances.last.due_date).to eq Date.parse("2015-06-16")
            end
          end

          describe "with a future_start_rule of 'time_span'" do
            before do
              @recurrence.update_columns future_start_rule: "time_span", future_start_schedule: "days", future_start_frequency: 10
            end
      
            it "should generate one new event starting after the time span from today" do
              expect {
                RecurringDriverCompliance.generate!
              }.to change(DriverCompliance, :count).by(1)

              expect(@driver.driver_compliances.last.due_date).to eq Date.parse("2015-06-18")
            end
          end
        end
      end
    end
  end
end

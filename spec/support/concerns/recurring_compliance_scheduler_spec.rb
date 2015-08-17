require 'spec_helper'

# For model specs
RSpec.shared_examples "a recurring compliance event scheduler" do
  describe "occurrence" do
    before do
      # Set @occurrence_owner_class in the described class, i.e. Driver or
      # Vehicle
      fail "@occurrence_owner_class instance variable required" unless defined? @occurrence_owner_class

      # Set @occurrence_class in the described class, i.e. DriverCompliance or
      # VehicleMaintenanceCompliance
      fail "@occurrence_class instance variable required" unless defined? @occurrence_class
      
      # Set @occurrence_association in the described class, i.e
      # :driver_compliances or :vehicle_maintenance_compliances
      fail "@occurrence_association instance variable required" unless defined? @occurrence_association
      
      @occurrence_owner_class_factory = @occurrence_owner_class.name.underscore.to_sym
      @occurrence_class_factory = @occurrence_class.name.underscore.to_sym
      @occurrence_association = @occurrence_class.name.pluralize.underscore.to_sym
      @described_class_factory = described_class.name.underscore.to_sym
    end

    it "requires a provider" do
      recurrence = build @described_class_factory, provider: nil
      expect(recurrence.valid?).to be_falsey
      expect(recurrence.errors.keys).to include :provider
    end

    it "requires an event_name" do
      recurrence = build @described_class_factory, event_name: nil
      expect(recurrence.valid?).to be_falsey
      expect(recurrence.errors.keys).to include :event_name
    end

    # The described class may decide this is not a required field, but the
    # values should still be restricted to this list
    it "requires a recurrence_schedule be one of 'days', 'weeks', 'months', or 'years'" do
      recurrence = build @described_class_factory, recurrence_schedule: "foo"
      expect(recurrence.valid?).to be_falsey
      expect(recurrence.errors.keys).to include :recurrence_schedule

      %w(days weeks months years).each do |schedule|
        recurrence.recurrence_schedule = schedule
        expect(recurrence.valid?).to be_truthy
      end
    end

    # The described class may decide this is not a required field, but the
    # values should still be restricted to an integer greater than 0
    it "requires a numeric recurrence_frequency greater than 0" do
      recurrence = build @described_class_factory, recurrence_frequency: nil

      %w(foo -1 0).each do |frequency|
        recurrence.recurrence_frequency = frequency
        expect(recurrence.valid?).to be_falsey
        expect(recurrence.errors.keys).to include :recurrence_frequency
      end

      recurrence.recurrence_frequency = "1"
      expect(recurrence.valid?).to be_truthy
    end

    it "requires a valid start_date on or after today" do
      recurrence = build @described_class_factory, start_date: nil
      expect(recurrence.valid?).to be_falsey
      expect(recurrence.errors.keys).to include :start_date

      recurrence.start_date = Date.current
      expect(recurrence.valid?).to be_truthy
    end

    it "requires a future_start_rule of either 'immediately', 'on_schedule' (i.e. based on start_date), or 'time_span'" do
      recurrence = build @described_class_factory, future_start_rule: nil, future_start_schedule: "days", future_start_frequency: 1
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

    it "requires a future_start_schedule of either 'days', 'weeks', 'months', or 'years' when future_start_rule is 'time_span'" do
      recurrence = build @described_class_factory, future_start_rule: 'time_span', future_start_schedule: nil, future_start_frequency: 1
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

    it "requires a numeric future_start_frequency greater than 0 when future_start_rule is 'time_span'" do
      recurrence = build @described_class_factory, future_start_rule: 'time_span', future_start_schedule: 'days', future_start_frequency: nil
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

    it "does not automatically generate child compliance events on creation (allowing for a period of time to modify the new event)" do
      expect {
        create @described_class_factory
      }.not_to change(@occurrence_class, :count)
    end
  
    describe "updates" do
      it "only allows the recurrence_notes, event_name, and event_notes fields to be modified once it has spawned children" do
        recurrence = create @described_class_factory, event_name: "My Event", event_notes: nil, recurrence_notes: nil
        create @occurrence_class_factory, @described_class_factory => recurrence

        recurrence.start_date = Date.tomorrow
        expect(recurrence.valid?).to be_falsey
        expect(recurrence.errors.keys).to include :start_date

        recurrence.reload
        recurrence.event_name = "My New Event"
        recurrence.event_notes = "My Event Notes"
        recurrence.recurrence_notes = "My Recurrence Notes"
        expect(recurrence.valid?).to be_truthy
      end

      it "pushes changes to event_name and event_notes fields to children" do
        recurrence = create @described_class_factory, event_name: "My Event", event_notes: nil
        compliance_occurrence = create @occurrence_class_factory, @described_class_factory => recurrence

        expect {
          recurrence.update_attributes event_name: "My Update Event Name", event_notes: "My Updated Event Notes"
        }.to change { [compliance_occurrence.reload.event, compliance_occurrence.reload.notes] }.to(["My Update Event Name", "My Updated Event Notes"])
      end
    end

    describe "#destroy" do
      it "nullifies the association on children when destroyed, by default" do
        recurrence = create @described_class_factory, event_name: "My Event", event_notes: nil
        compliance_occurrence = create @occurrence_class_factory, @described_class_factory => recurrence

        expect {
          recurrence.destroy
        }.to change(described_class, :count).by(-1)
        expect(compliance_occurrence.reload.send(@described_class_factory)).to be_nil
      end

      it "can optionally delete incomplete children when destroyed, but will still nullify complete children" do
        recurrence = create @described_class_factory, event_name: "My Event", event_notes: nil
        compliance_occurrence_1 = create @occurrence_class_factory, compliance_date: Date.current, @described_class_factory => recurrence
        compliance_occurrence_2 = create @occurrence_class_factory, @described_class_factory => recurrence
        compliance_occurrence_3 = create @occurrence_class_factory, :recurring

        expect {
          recurrence.destroy_with_incomplete_children!
        }.to change(described_class, :count).by(-1)
        expect(compliance_occurrence_1.reload.send(@described_class_factory)).to be_nil
        expect(@occurrence_class.all).to include compliance_occurrence_1
        expect(@occurrence_class.all).not_to include compliance_occurrence_2
        expect(@occurrence_class.all).to include compliance_occurrence_3
      end
    end

    describe ".generate!" do
      before do
        # Time.now is now frozen at Monday, June 1, 2015
        Timecop.freeze(Date.parse("2015-06-01"))

        # Start date is Tuesday, June 2, 2015
        @recurrence = create @described_class_factory,
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
      
      # The described class should verify the implementation
      it "defines a .generate! class method"

      # All implementations should at least pass these smoke tests
      describe "sanity check" do
        before do
          @owner = create @occurrence_owner_class_factory, provider: @provider
        end

        it "generates child compliance events for occurrence owners of providers with recurrences defined" do
          expect {
            described_class.generate!
          }.to change { @owner.send(@occurrence_association).count }
        end

        it "doesn't generates child compliance events for occurrence owners of providers without recurrences defined" do
          owner_2 = create @occurrence_owner_class_factory
          expect {
            described_class.generate!
          }.not_to change { owner_2.send(@occurrence_association).count }
        end

        it "sets the name and notes of generated children to the recurrence's event_name and event_notes fields, respectively" do
          described_class.generate!
          expect(@owner.send(@occurrence_association).first.event).to eq "Submit timesheet"
          expect(@owner.send(@occurrence_association).first.notes).to eq "Don't forget!"
        end

        it "is idempotent" do
          described_class.generate!
          expect {
            described_class.generate!
          }.not_to change(@occurrence_class, :count)
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe RecurringVehicleMaintenanceCompliance, type: :model do
  it_behaves_like "a recurring compliance event scheduler" do
    before do
      # These options reflect the concern setup method:
      # creates_occurrences_for :vehicle_maintenance_compliances, on: :vehicles
      @occurrence_association = :vehicle_maintenance_compliances
      @occurrence_owner_association = :vehicles
    end
  end
  
  # This field is specific to RecurringVehicleMaintenanceCompliance
  it "requires a recurrence_type"

  # The "a recurring compliance event scheduler" shared examples already test
  # appropriate values. We're just testing that the value is reuired under
  # certain conditions
  it "requires a recurrence_schedule when recurrence type is 'date' or 'both'"

  # The "a recurring compliance event scheduler" shared examples already test
  # appropriate values. We're just testing that the value is reuired under
  # certain conditions
  it "requires a recurrence_frequency when recurrence type is 'date' or 'both'"
  
  # This field is specific to RecurringVehicleMaintenanceCompliance
  it "requires a recurrence_mileage when recurrence type is 'mileage' or 'both'"

  # This field is specific to RecurringVehicleMaintenanceCompliance
  it "requires a numeric recurrence_mileage greater than 0 when recurrence type is 'mileage' or 'both'"
  
  # The "a recurring compliance event scheduler" shared examples already test
  # occurrence generation for date based scheduling. The specs below exercise
  # functionality specific to RecurringVehicleMaintenanceCompliance, 
  # specifically when the recurrence_type is 'mileage' or 'both'
  describe "custom methods" do
    before do
      @recurrence = create :recurring_vehicle_maintenance_compliance
      @provider = @recurrence.provider
      @vehicle = create :vehicle, provider: @provider
    end
  
    describe ".occurrences_on_schedule_in_range" do
      describe "when the recurrence_type is 'date'" do
        it "falls back to the .occurrence_dates_on_schedule_in_range method" do
          expect(RecurringVehicleMaintenanceCompliance).to receive :occurrence_dates_on_schedule_in_range
          RecurringVehicleMaintenanceCompliance.occurrences_on_schedule_in_range @recurrence
        end
      end

      describe "when the recurrence_type is 'mileage'" do
      end

      describe "when the recurrence_type is 'both'" do
      end
    end
  
    describe ".next_occurrence_from_previous_in_range" do
      describe "when the recurrence_type is 'date'" do
        it "falls back to the .next_occurrence_date_from_previous_date_in_range method" do
          expect(RecurringVehicleMaintenanceCompliance).to receive :next_occurrence_date_from_previous_date_in_range
          RecurringVehicleMaintenanceCompliance.next_occurrence_from_previous_in_range @recurrence, Date.current, 0
        end
      end

      describe "when the recurrence_type is 'mileage'" do
      end

      describe "when the recurrence_type is 'both'" do
      end
    end

    describe ".generate!" do
      it "invokes our custom generator" do
        expect(RecurringVehicleMaintenanceCompliance).to receive :custom_vehicle_maintenance_compliance_generator
        RecurringVehicleMaintenanceCompliance.generate!
      end
    
      describe "when the recurrence_type is 'date'" do
        it "falls back to the .default_generator method" do
          expect(RecurringVehicleMaintenanceCompliance).to receive :default_generator
          RecurringVehicleMaintenanceCompliance.generate!
        end
      end

      describe "when the recurrence_type is 'mileage'" do
      end

      describe "when the recurrence_type is 'both'" do
      end
    end
  end
end

class RecurringVehicleMaintenanceCompliance < ActiveRecord::Base
  include RecurringComplianceEventScheduler
  creates_occurrences_for :vehicle_maintenance_compliances, on: :vehicles
  generates_occurrences_with do |recurrence, collection|
    custom_vehicle_maintenance_compliance_generator recurrence, collection
  end
  make_occurence_with_attributes do |owner, recurrence, *opts|
    options = opts.extract_options!
    default_occurrence_attributes(owner, recurrence, options[:occurrence_date]).merge({
      due_type: options[:occurrence_type] || 'date',
      due_mileage: options[:occurrence_mileage]
    })
  end

  validates :recurrence_type, inclusion: { in: VehicleMaintenanceCompliance::DUE_TYPES.map(&:to_s) }
  validates :recurrence_schedule, presence: { if: :recurrence_schedule_required? }
  validates :recurrence_frequency, presence: { if: :recurrence_schedule_required? }
  validates :recurrence_mileage, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :recurrence_mileage, presence: { if: :recurrence_mileage_required? }

  class << self
    def occurrences_on_schedule_in_range(recurrence, first_date: nil, range_start_date: nil, range_end_date: nil, first_mileage: nil, range_start_mileage: nil, range_end_mileage: nil)
      if recurrence.recurrence_type.to_sym == :date
        occurrence_dates_on_schedule_in_range(recurrence, first_date: first_date, range_start_date: range_start_date, range_end_date: range_end_date)
      else
        raise "TODO"
      end
    end

    def next_occurrence_from_previous_in_range(recurrence, previous_date, previous_mileage, range_end_date: nil, range_end_mileage: nil)
      if recurrence.recurrence_type.to_sym == :date
        next_occurrence_date_from_previous_date_in_range(recurrence, previous_date, range_end_date: range_end_date)
      else
        raise "TODO"
      end
    end
  
    private
    
    def custom_vehicle_maintenance_compliance_generator(recurrence, collection)
      if recurrence.recurrence_type.to_sym == :date
        default_generator recurrence, collection
      else
        if recurrence.compliance_based_scheduling?
          schedule_vehicle_maintenance_compliance_based_occurrences! recurrence, collection
        else
          schedule_vehicle_maintenance_frequency_based_occurrences! recurrence, collection
        end
      end
    end
    
    def schedule_vehicle_maintenance_compliance_based_occurrences!(recurrence, collection)
      raise "TODO"
    end
    
    def schedule_vehicle_maintenance_frequency_based_occurrences!(recurrence, collection)
      raise "TODO"
    end
    
    def default_mileage_range_length
      @default_mileage_range_length || 6000
    end
  end

  private

  def recurrence_schedule_required?
    [:both, :date].include? recurrence_type.try(:to_sym)
  end
  
  def recurrence_mileage_required?
    [:both, :mileage].include? recurrence_type.try(:to_sym)
  end
end

class RecurringDriverCompliance < ActiveRecord::Base
  include RecurringComplianceEventScheduler
  creates_occurrences_on :driver_compliances
  
  has_many :drivers, through: :provider
  has_many :driver_compliances, :dependent => :nullify, inverse_of: :recurring_driver_compliance
  
  validates :recurrence_schedule, presence: true
  validates :recurrence_frequency, presence: true
  validates :compliance_date_based_scheduling, inclusion: { in: [true, false] }
  
  class << self
    def generate!(range_length: nil)
      # Defaults to 6 months, but can be set longer
      @default_range_length = range_length
      
      transaction do
        find_each do |recurrence|
          # Ensures that the next steps all work off the same collection
          drivers = recurrence.drivers

          if recurrence.compliance_date_based_scheduling?
            schedule_compliance_date_based_occurrences! recurrence, drivers
          else
            schedule_due_date_based_occurrences! recurrence, drivers
          end
        end
      end
    end
  
    def occurrence_dates_on_schedule_in_range(recurrence, first_date: nil, range_start_date: nil, range_end_date: nil)
      first_date ||= recurrence.start_date
      range_start_date ||= Date.current
      range_end_date ||= (range_start_date + default_range_length - 1.day)
      next_date = first_date
      
      occurrences = []
      iterator = 0
      loop do
        break if next_date > range_end_date
        occurrences << next_date if next_date >= range_start_date
        next_date = first_date + (recurrence.recurrence_frequency * (iterator += 1)).send(recurrence.recurrence_schedule)
      end
      occurrences
    end
    
    # Public for testability purposes
    def next_occurrence_date_from_previous_date_in_range(recurrence, previous_date, range_end_date: nil)
      range_end_date ||= (Date.current + default_range_length - 1.day)
      next_date = previous_date + recurrence.recurrence_frequency.send(recurrence.recurrence_schedule)
      
      if next_date > range_end_date
        nil
      else
        next_date
      end
    end
  
    # Public for testability purposes
    def adjusted_start_date(recurrence, as_of: nil)
      as_of ||= Date.current

      if recurrence.start_date >= as_of
        recurrence.start_date
      else
        case recurrence.future_start_rule.to_sym
        when :immediately
          as_of
        when :on_schedule
          occurrence_dates_on_schedule_in_range(recurrence, range_start_date: as_of, range_end_date: (as_of + recurrence.recurrence_frequency.send(recurrence.recurrence_schedule))).first
        when :time_span
          as_of + recurrence.future_start_frequency.send(recurrence.future_start_schedule)
        end
      end
    end

    private
    
    def schedule_compliance_date_based_occurrences!(recurrence, driver_collection)
      driver_collection.find_each do |driver|
        previous_occurrences = recurrence.driver_compliances.for_driver(driver)

        if previous_occurrences.any?
          if previous_occurrences.last.complete?
            # Schedule it based on whenever this one was complete
            next_occurence_date = next_occurrence_date_from_previous_date_in_range recurrence, previous_occurrences.last.compliance_date
          else
            # Nothing to schedule as the last one is still incomplete
            # noop
          end
        else
          # No previous one, schedule based on the adjusted start date
          next_occurence_date = adjusted_start_date(recurrence)
        end

        make_occurrence!(driver, recurrence, next_occurence_date) if next_occurence_date.present?
      end
    end
    
    def schedule_due_date_based_occurrences!(recurrence, driver_collection)
      driver_collection.find_each do |driver|
        previous_occurrences = recurrence.driver_compliances.for_driver(driver)
        next_occurence_dates = []

        if previous_occurrences.any?
          # Find missing occurrence dates in range
          next_occurence_dates = occurrence_dates_on_schedule_in_range(recurrence) - previous_occurrences.pluck(:due_date)
        else
          # Find missing occurrence rates based on the adjusted start date
          next_occurence_dates = occurrence_dates_on_schedule_in_range recurrence, first_date: adjusted_start_date(recurrence)
        end

        next_occurence_dates.each do |occurrence_date|
          make_occurrence! driver, recurrence, occurrence_date
        end
      end
    end
    
    def make_occurrence!(driver, recurrence, occurrence_date)
      driver.driver_compliances.create! event: recurrence.event_name,
        notes: recurrence.event_notes,
        due_date: occurrence_date,
        recurring_driver_compliance: recurrence
    end
    
    def default_range_length
      @default_range_length || 6.months
    end
  end  
end

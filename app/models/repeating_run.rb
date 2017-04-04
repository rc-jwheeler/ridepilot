# This is a 'dumb' model. It is managed by a Run instance, which creates a 
# repeating instance of itself when instructed to. Validation is nonexistent 
# since all data should already have been vetted by the Run instance.
class RepeatingRun < ActiveRecord::Base
  include RecurringRideCoordinatorScheduler

  has_paper_trail

  belongs_to :vehicle, -> { with_deleted }
  belongs_to :driver, -> { with_deleted }
  belongs_to :provider, -> { with_deleted }

  scope :active, -> { where("(start_date is NULL or start_date <= ?) AND (end_date is NULL or end_date >= ?)", Date.today, Date.today) }

  def instantiate!
    return unless active? 

    now = Date.today + 1.day
    later = now.advance(days: (provider.try(:advance_day_scheduling) || Provider::DEFAULT_ADVANCE_DAY_SCHEDULING) - 1)
    RepeatingRun.transaction do
      for date in schedule.occurrences_between(now, later)
        unless Run.repeating_based_on(self).for_date(date).exists?
          attributes = self.attributes.select{ |k, v| RepeatingRun.ride_coordinator_attributes.include? k.to_s }
          attributes["date"] = date
          attributes["repeating_run_id"] = id
          attributes["via_recurring_ride_coordinator_scheduler"] = true
          run = Run.new attributes
          # debugger unless run.valid?
          run.save!
        end
      end
    end
  end

  def active?
    active = true

    today = Date.today
    active = false if (start_date && today < start_date) || (end_date && today > end_date)

    active
  end
end

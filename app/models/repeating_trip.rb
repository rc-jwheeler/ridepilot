# This is a 'dumb' model. It is managed by a Trip instance, which creates a 
# repeating instance of itself when instructed to. Validation is nonexistent 
# since all data should already have been vetted by the Trip instance.
class RepeatingTrip < ActiveRecord::Base
  include RequiredFieldValidatorModule
  include RecurringRideCoordinatorScheduler
  include RecurringRideCoordinator
  include TripCore

  has_paper_trail

  schedules_occurrences_with :repeating_trip,
    with_attributes: -> (trip) {
      attrs = {}
      RepeatingTrip.ride_coordinator_attributes.each {|attr| attrs[attr] = trip.send(attr) }
      attrs['driver_id'] = trip.repetition_driver_id
      attrs['vehicle_id'] = trip.repetition_vehicle_id
      attrs['schedule_attributes'] = {
        repeat:        1,
        interval_unit: "week", 
        start_date:    trip.pickup_time.to_date.to_s,
        interval:      trip.repetition_interval, 
        monday:        trip.repeats_mondays    ? 1 : 0,
        tuesday:       trip.repeats_tuesdays   ? 1 : 0,
        wednesday:     trip.repeats_wednesdays ? 1 : 0,
        thursday:      trip.repeats_thursdays  ? 1 : 0,
        friday:        trip.repeats_fridays    ? 1 : 0,
        saturday:      trip.repeats_saturdays  ? 1 : 0,
        sunday:        trip.repeats_sundays    ? 1 : 0
      }
      attrs
    },
    destroy_future_occurrences_with: -> (trip) {
      # Be sure not delete occurrences that have already happened.
      trips = if trip.pickup_time < Time.zone.now
        Trip.repeating_based_on(trip.repeating_trip).after_today.not_called_back
      else 
        Trip.repeating_based_on(trip.repeating_trip).after(trip.pickup_time).not_called_back
      end

      schedule = trip.repeating_trip.schedule
      Trip.transaction do
        trips.find_each do |t|
          t.destroy unless schedule.occurs_on?(t.pickup_time)
        end
      end
    },
    destroy_all_future_occurrences_with: -> (trip) {
      # Be sure not delete occurrences that have already happened.
      trips = if trip.pickup_time < Time.zone.now
        Trip.repeating_based_on(trip.repeating_trip).after_today.not_called_back
      else 
        Trip.repeating_based_on(trip.repeating_trip).after(trip.pickup_time).not_called_back
      end

      trips.destroy_all
    },
    unlink_past_occurrences_with: -> (trip) {
      if trip.pickup_time < Time.zone.now
        Trip.repeating_based_on(trip.repeating_trip).today_and_prior.update_all "repeating_trip_id = NULL"
      else 
        Trip.repeating_based_on(trip.repeating_trip).prior_to(trip.pickup_time).update_all "repeating_trip_id = NULL"
      end
    }


  belongs_to :driver, -> { with_deleted } 
  belongs_to :vehicle, -> { with_deleted }
 
  scope :active, -> { where("(start_date is NULL or start_date <= ?) AND (end_date is NULL or end_date >= ?)", Date.today, Date.today) }
  
  def instantiate!
    return unless active? 

    now = Date.today + 1.day
    later = now.advance(days: (provider.try(:advance_day_scheduling) || Provider::DEFAULT_ADVANCE_DAY_SCHEDULING) - 1)
    RepeatingTrip.transaction do
      for date in schedule.occurrences_between(now, later)
        this_trip_pickup_time = Time.zone.local(date.year, date.month, date.day, pickup_time.hour, pickup_time.min, pickup_time.sec)
      
        unless Trip.repeating_based_on(self).for_date(date).exists?
          attributes = self.attributes.select{ |k, v| RepeatingTrip.ride_coordinator_attributes.include? k.to_s }
          attributes["repeating_trip_id"] = id
          attributes["pickup_time"] = this_trip_pickup_time
          attributes["appointment_time"] = this_trip_pickup_time + (appointment_time - pickup_time)
          attributes["via_recurring_ride_coordinator_scheduler"] = true
          trip = Trip.new attributes
          # debugger unless trip.valid?
          trip.save!
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

  def name
    
  end
end

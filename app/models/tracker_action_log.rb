# a wrapper over public_activity gem
class TrackerActionLog < PublicActivity::Activity

  scope :for, -> (trackable) { where(trackable: trackable) }

  def self.create_return_trip(return_trip, user)
    if return_trip
      return_trip.create_activity :return_created, owner: user 
      outbound_trip = return_trip.outbound_trip
      outbound_trip.create_activity :create_return, owner: user if outbound_trip
    end
  end

  def self.cancel_or_turn_down_trip(trip, user)
    if trip && trip.is_cancelled_or_turned_down?
      action = trip.trip_result.turned_down? ? :trip_turned_down : :trip_cancelled
      trip.create_activity action, owner: user, params: {
        trip_result: trip.trip_result.try(:name), 
        reason: trip.result_reason
      }
    end
  end

  def self.create_subscription_trip(trip, user)
    if trip 
      trip.create_activity :subscription_created, owner: user
    end
  end

  def self.update_subscription_trip(trip, user, changes, is_schedule_changed)
    if trip
      params = {}
      changes.each do |k, change|
        case k
        when 'pickup_time'
          params["Pickup Time"] = trip.pickup_time.strftime('%I:%M%P') if !compare_time_only(change[0], change[1])
        when 'appointment_time'
          params["Appointment Time"] = trip.appointment_time.strftime('%I:%M%P') if !compare_time_only(change[0], change[1])
        when 'pickup_address_id'
          params["Pickup Address"] = trip.pickup_address.address_text if trip.pickup_address
        when 'dropoff_address_id'
          params["Dropoff Address"] = trip.dropoff_address.address_text if trip.dropoff_address
        when 'customer_id'
          params["Customer"] = trip.customer.name if trip.customer
        when 'trip_purpose_id'
          params["Trip Purpose"] = trip.trip_purpose.try(:name)
        when 'mobility_id'
          params["Mobility"] = trip.mobility.try(:name)
        when 'guest_count'
          params["Guests"] = trip.guest_count
        when 'attendant_count'
          params["Attendants"] = trip.attendant_count
        when 'group_size'
          params["Group Size"] = trip.group_size
        when 'mobility_device_accommodations'
          params["Mobility Device Count"] = trip.mobility_device_accommodations
        when 'start_date'
          params["Start Date"] = trip.start_date.try(:strftime, "%B %d, %Y")
        when 'end_date'
          params["End Date"] = trip.end_date.try(:strftime, "%B %d, %Y")
        when 'schedule_yaml'
          params["Schedule"] = trip.schedule.to_s
        end
      end

      if is_schedule_changed
        params["Schedule"] = trip.schedule.to_s
      end

      trip.create_activity :subscription_updated, owner: user, params: params unless params.blank?
    end
  end

  def self.change_vehicle_initial_mileage(vehicle, user)
    if vehicle 
      vehicle.create_activity :initial_mileage_changed, owner: user, params: {
        mileage: vehicle.initial_mileage, 
        reason: vehicle.initial_mileage_change_reason
      }
    end
  end

  private

  def self.compare_time_only(time_1, time_2)
    time_1.utc.strftime( "%H%M%S%N" ) == time_2.utc.strftime( "%H%M%S%N" )
  end
end
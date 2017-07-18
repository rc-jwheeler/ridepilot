module DispatchHelper

  def get_itineraries(trips)
    itins = []

    trips.each do |trip|
      trip_data = {
        trip_id: trip.id,
        customer: trip.customer.try(:name),
        comments: trip.notes 
      }
      itins << trip_data.merge(
        action: 'Pickup',
        time: trip.pickup_time,
        address: trip.pickup_address.try(:one_line_text)
      )
      itins << trip_data.merge(
        action: 'Dropoff',
        time: trip.appointment_time,
        address: trip.dropoff_address.try(:one_line_text)
      )
    end

    itins.sort_by { |hsh| hsh[:time] }
  end

  def run_summary(run)
    if run
      "Vehicle: #{run.vehicle.try(:name) || (empty)}, " +
      "Driver: #{run.driver.try(:name) || (empty)}, " + 
      "Run Time: #{format_time_for_listing(run.scheduled_start_time)} - #{format_time_for_listing(run.scheduled_end_time)}" 
    end
  end

end
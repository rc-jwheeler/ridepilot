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
      trip.create_activity action, owner: user, params: {trip_result: trip.trip_result.try(:name), reason: trip.result_reason}
    end
  end
end
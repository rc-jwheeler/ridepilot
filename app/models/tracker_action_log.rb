# a wrapper over public_activity gem
class TrackerActionLog < PublicActivity::Activity

  scope :for, -> (trackable) { where(trackable: trackable) }

  def self.create_return_trip(outbound_trip, user)
    outbound_trip.create_activity :create_return, owner: user if outbound_trip
  end
end
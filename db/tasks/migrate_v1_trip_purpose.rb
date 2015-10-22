# migrate existing trip_purpose data in trips, repeating_trips, address table
Trip.all.each do |trip|
  trip.update trip_purpose: TripPurpose.find_by(name: trip.trip_purpose_old)
end
RepeatingTrip.all.each do |trip|
  trip.update trip_purpose: TripPurpose.find_by(name: trip.trip_purpose_old)
end
Address.all.each do |addr|
  addr.update trip_purpose: TripPurpose.find_by(name: addr.trip_purpose_old)
end
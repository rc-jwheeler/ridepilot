# migrate existing trip_result data in Trips table
Trip.all.each do |trip|
  trip.update trip_result: TripResult.find_by(code: trip.trip_result_old)
end
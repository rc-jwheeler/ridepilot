class OtpDistanceDurationService < AbstractDistanceDurationService
  
  TRIP_PLANNER_URL = ENV['OPEN_TRIP_PLANNER_URL']

  private

  def build_url
    time = @trip_datetime.strftime("%-I:%M%p")
    date = @trip_datetime.strftime("%Y-%m-%d")

    url_options = "mode=CAR"
    url_options += "&date=#{date}"
    url_options += "&time=#{time}"
    url_options += "&fromPlace=#{@from_lat.to_s},#{@from_lon.to_s}" 
    url_options += "&toPlace=#{@to_lat.to_s},#{@to_lon.to_s}"

    TRIP_PLANNER_URL + url_options
  end

  def parse_response(result)
    if result.has_key? 'error' and not result['error'].nil?
      Rails.logger.error "Service failure: fixed: result has error: #{result['error']}"
      return false, result['error']
    else
      return true, result['plan']
    end
  end

  # in seconds
  def parse_drive_time(response)
    itinerary = response['itineraries'].try(:first) if response
    
    itinerary['duration'] rescue nil
  end

  # in miles
  def parse_drive_distance(response)
    itinerary = response['itineraries'].try(:first) if response
    
    itinerary['legs'].first['distance'] * METERS_TO_MILES rescue nil
  end

end

require 'json'
require 'net/http'

class TripPlanner
  attr_reader :from_lat, :from_lon, :to_lat, :to_lon, :trip_datetime

  OPEN_TRIP_PLANNER_URL = ENV['OPEN_TRIP_PLANNER_URL']
  METERS_TO_MILES = 0.000621371192

  def initialize(from_lat, from_lon, to_lat, to_lon, trip_datetime)
    @from_lat = from_lat
    @from_lon = from_lon
    @to_lat = to_lat
    @to_lon = to_lon
    @trip_datetime = trip_datetime
  end

  def get_drive_itineraries(try_count=3)
    return nil if !OPEN_TRIP_PLANNER_URL.present?

    try = 1
    result = nil
    response = nil

    while try <= try_count
      result, response = get_drive_itineraries_once
      if result
        break
      else
        Rails.logger.info [@from_lat, @from_lon, @to_lat, @to_lon, @trip_datetime]
        Rails.logger.info response
        Rails.logger.info "Try " + try.to_s + " failed."
        Rails.logger.info "Trying again..."

      end
      sleep([try,3].min) #The first time wait 1 second, the second time wait 2 seconds, wait 3 seconds every time after that.
      try +=1
    end

    return result, response

  end

  def get_drive_itineraries_once
    url = build_url
    Rails.logger.info url
   
    t = Time.now
    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      Rails.logger.info(resp[:ai])
    rescue Exception=>e
      Rails.logger.error "Service failure(url: #{url}): fixed: #{e.message}"
      return false, {'id'=>500, 'msg'=>e.to_s}
    end

    if resp.code != "200"
      Rails.logger.error "Service failure: fixed: resp.code not 200, #{resp.message}"
      return false, {'id'=>resp.code.to_i, 'msg'=>resp.message}
    end

    data = resp.body
    result = JSON.parse(data)
    if result.has_key? 'error' and not result['error'].nil?
      Rails.logger.error "Service failure: fixed: result has error: #{result['error']}"
      return false, result['error']
    else
      return true, result['plan']
    end

  end

  def get_drive_time
    result, response = get_drive_itineraries
    itinerary = response['itineraries'].try(:first)
    
    itinerary['duration'] rescue nil
  end

  def get_drive_distance
    result, response = get_drive_itineraries
    itinerary = response['itineraries'].try(:first)
    
    itinerary['legs'].first['distance'] * METERS_TO_MILES rescue nil
  end

  private

  def build_url
    time = @trip_datetime.strftime("%-I:%M%p")
    date = @trip_datetime.strftime("%Y-%m-%d")

    url_options = "mode=CAR"
    url_options += "&date=#{date}"
    url_options += "&time=#{time}"
    url_options += "&fromPlace=#{@from_lat.to_s},#{@from_lon.to_s}" 
    url_options += "&toPlace=#{@to_lat.to_s},#{@to_lon.to_s}"

    OPEN_TRIP_PLANNER_URL + url_options
  end

end

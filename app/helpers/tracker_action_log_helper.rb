module TrackerActionLogHelper
  def formulate_log_message(log)
    return nil unless log 

    case log.key
    when "trip.create_return"
      return_trip = log.trackable.try(:return_trip)
      if return_trip.present?
        "Return trip (#{link_to return_trip.id, return_trip}) created.".html_safe
      end
    end
  end
end

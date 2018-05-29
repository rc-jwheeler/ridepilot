class DriverAlertChannel < ApplicationCable::Channel
  def subscribed
    stream_from "driver_alert_channel_#{params[:driver_user_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

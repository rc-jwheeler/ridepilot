class EmergencyAlertDismissWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'high_critical'

  def perform(alert_id)
    Rails.logger.info "EmergencyAlertDismissWorker#perform, alert_id=#{alert_id}"

    alert = EmergencyAlert.find_by_id alert_id
    if alert
      ActionCable.server.broadcast "alert_channel_#{alert.provider_id}", {id: alert_id, dismiss: true}
      if alert.reader
        ActionCable.server.broadcast "driver_alert_channel_#{alert.sender_id}", {action: 'ReceiveAlert', message: "Alert has been received by #{alert.reader.display_name}"}
      end
    end
  end
end

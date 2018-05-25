class EmergencyAlertDismissWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'high_critical'

  def perform(alert_id, provider_id)
    Rails.logger.info "EmergencyAlertDismissWorker#perform, alert_id=#{alert_id}"
    ActionCable.server.broadcast "alert_channel_#{provider_id}", {id: alert_id, dismiss: true}
  end
end

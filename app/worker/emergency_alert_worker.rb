class EmergencyAlertWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'high_critical'

  def perform(alert_id, provider_id, message)
    Rails.logger.info "EmergencyAlertWorker#perform, provider_id=#{provider_id}"
    ActionCable.server.broadcast "alert_channel_#{provider_id}", {id: alert_id, provider_id: provider_id, message: message}
  end
end

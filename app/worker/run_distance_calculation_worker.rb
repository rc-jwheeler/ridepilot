class RunDistanceCalculationWorker
  include Sidekiq::Worker

  def perform(run_id)
    Rails.logger.info "RunDistanceCalculationWorker#perform, Run ID = #{run_id}"
    begin
      RunDistanceCalculator.new(run_id).process
    rescue Exception => ex
      puts ex.message
    end
  end
end

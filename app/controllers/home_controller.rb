class HomeController < ApplicationController

  def index
    authorize! :read, current_user
  end

  def schedule_recurring
    if !Rails.env.production? || ENV['HAS_RECURRING_TRIP_RUN_SCHDULING_BUTTON'] == 'true'
      RepeatingRun.active.generate!
      RepeatingTrip.active.generate!
      Run.today_and_future.batch_update_recurring_trip_assignment!
    end

    redirect_back(fallback_location: admin_path)
  end

  private

  def get_base_funding_sources
    if params[:provider] == 'true'
      @funding_sources = FundingSource.provider_specific(current_provider_id).order(:name)
    else
      authorize! :manage, :all
      @funding_sources = FundingSource.across_system.order(:name)
    end
  end
end

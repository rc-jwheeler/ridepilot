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

    redirect_to :back 
  end
end

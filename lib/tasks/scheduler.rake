# This is added to run scheduler on heroku
# Heroku_scheduler requires a rake task
# This is also called by WHenever gem to schedule
namespace :scheduler do

  task run: :environment do
    # Schedule repeating trips
    RepeatingTrip.active.generate!

    # Schedule repeating runs
    RepeatingRun.active.generate!

    # Update run status
    Run.update_prior_run_complete_status!

    # Schedule recurring driver compliance events 5 years out
    RecurringDriverCompliance.generate! date_range_length: 5.years

    # Schedule recurring vehicle maintenance compliance events 5 years and 30000
    # miles out
    RecurringVehicleMaintenanceCompliance.generate! date_range_length: 5.years, mileage_range_length: 30_000

  end
end
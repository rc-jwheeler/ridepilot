# This is added to run scheduler on heroku
# Heroku_scheduler requires a rake task
namespace :scheduler do

  task run: :environment do
    # Schedule repeating trips
    RepeatingTrip.generate!

    # Schedule repeating runs
    RepeatingRun.generate!

    # Schedule recurring driver compliance events 5 years out
    RecurringDriverCompliance.generate! date_range_length: 5.years

    # Schedule recurring vehicle maintenance compliance events 5 years and 30000
    # miles out
    RecurringVehicleMaintenanceCompliance.generate! date_range_length: 5.years, mileage_range_length: 30_000

  end
end
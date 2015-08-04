# Cron job scheduler. Integrates with Capistrano, or update your custom 
# deployments to manually execute whenever. See `bundle exec whenever --help` 
# for details

every 1.day, :at => '12:00 am' do
  # Schedule repeating trips
  runner "RepeatingTrip.create_trips"

  # Schedule recurring events 5 years out
  runner "RecurringDriverCompliance.generate! range_length: 5.years"
end

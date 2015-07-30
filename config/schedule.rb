# Cron job scheduler. Integrates with Capistrano, or update your custom 
# deployments to manually execute whenever. See `bundle exec whenever --help` 
# for details

# Schedule repeating trips
every 1.day, :at => '12:00 am' do
  runner "RepeatingTrip.create_trips"       
end

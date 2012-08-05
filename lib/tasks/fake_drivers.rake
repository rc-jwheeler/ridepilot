namespace :test do
  desc "Move fake drivers around on the map."
  task :fake_drivers => :environment do
    CENTER_LAT = 45.523
    CENTER_LNG = -122.676
    print 'Moving drivers'
    while true do
      print '.'
      STDOUT.flush
      DevicePoolDriver.all.each do |driver|
        driver.status = 'active'
        if driver.lat.blank? then driver.lat = CENTER_LAT.to_s end
        if driver.lng.blank? then driver.lng = CENTER_LNG.to_s end
        # Move a small random amount
        lat_offset = (Random.rand(20)-10)/1000.0
        lng_offset = (Random.rand(20)-10)/1000.0
        lat = driver.lat.to_f + lat_offset
        lng = driver.lng.to_f + lng_offset
        # Bounce back to center if it goes too far
        if lat > 45.65 or lat < 45.35 then lat = CENTER_LAT end
        if lng > -122.3 or lng < -123.0 then lng = CENTER_LNG end
        driver.lat = lat.to_s
        driver.lng = lng.to_s
        driver.posted_at = DateTime.now
        driver.save!
      end
      sleep(15)
    end
  end
end

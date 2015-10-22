# migrate existing service_level data in trips, customers table
Trip.all.each do |trip|
  trip.update service_level: ServiceLevel.find_by(name: trip.service_level_old)
end

Customer.all.each do |customer|
  customer.update service_level: ServiceLevel.find_by(name: customer.service_level_old)
end
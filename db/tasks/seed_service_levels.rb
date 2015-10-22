SERVICE_LEVELS = ["Wheelchair", "Ambulatory"] if !defined?(SERVICE_LEVELS)
  
SERVICE_LEVELS.each do |level|
  ServiceLevel.where(name: level).first_or_create
end

TRIP_PURPOSES = [
  "Life-Sustaining Medical", 
  "Medical", 
  "Nutrition", 
  "Personal/Support Services", 
  "Recreation", 
  "School/Work", 
  "Shopping", 
  "Volunteer Work", 
  "Center"] if !defined?(TRIP_PURPOSES)
  
TRIP_PURPOSES.each do |tp_name|
  TripPurpose.where(name: tp_name).first_or_create
end
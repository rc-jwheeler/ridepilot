class Itinerary < ApplicationRecord
  include ItineraryCore
  
  belongs_to :trip 
  belongs_to :run

  # STATUS CODE
  # 0 - Pending
  # 1 - In Progress
  # 2 - Completed
  # 3 - Done with exceptions: No Show etc
  STATUS_PENDING = 0
  STATUS_IN_PROGRESS = 1
  STATUS_COMPLETED = 2
  STATUS_OTHER = 3
end
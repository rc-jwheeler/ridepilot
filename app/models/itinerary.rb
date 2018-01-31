class Itinerary < ApplicationRecord
  include ItineraryCore
  
  belongs_to :trip 
  belongs_to :run
end
class PublicItinerary < ApplicationRecord
  belongs_to :itinerary, -> { with_deleted }
end

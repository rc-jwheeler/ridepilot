class VehicleCapacity < ActiveRecord::Base
  belongs_to :capacity_type
  belongs_to :vehicle_type

  validates :capacity_type, presence: true, uniqueness: true

  validates :capacity, presence: true, 
                    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :default_order, -> { joins(:capacity_type).order("capacity_types.name") }
end

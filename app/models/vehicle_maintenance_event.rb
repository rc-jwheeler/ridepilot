class VehicleMaintenanceEvent < ActiveRecord::Base
  has_paper_trail

  belongs_to :vehicle, inverse_of: :vehicle_maintenance_events
  
  validates_presence_of :vehicle

  scope :default_order, -> { order("service_date DESC") }
end

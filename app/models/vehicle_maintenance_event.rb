class VehicleMaintenanceEvent < ActiveRecord::Base
  belongs_to :provider
  belongs_to :vehicle
  
  has_paper_trail
end

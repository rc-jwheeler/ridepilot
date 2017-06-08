class VehicleMaintenanceSchedule < ActiveRecord::Base
  belongs_to :vehicle_maintenance_schedule_type

  validates :name, presence: true, uniqueness: { 
                    scope: :vehicle_maintenance_schedule_type, 
                    case_sensitive: false,
                    message: 'should be unique within a schedule type' }
  validates :mileage, presence: true, uniqueness: { 
                    scope: :vehicle_maintenance_schedule_type, 
                    case_sensitive: false,
                    message: 'should be unique within a schedule type' },
                    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :default_order, -> { order(:mileage, :name) }
end

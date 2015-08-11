class VehicleMaintenanceCompliance < ActiveRecord::Base
  DUE_TYPES = [:date, :mileage, :both].freeze
  
  belongs_to :vehicle, inverse_of: :vehicle_maintenance_compliances
  
  validates_presence_of :vehicle, :event
  validates :due_type, inclusion: { in: DUE_TYPES.map(&:to_s) }
  validates :due_date, presence: { if: :due_date_required? }
  validates_date :due_date, on_or_after: -> { Date.current }, allow_blank: true
  validates :due_mileage, presence: { if: :due_mileage_required? }
  validates :due_mileage, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates_date :compliance_date, on_or_before: -> { Date.current }, allow_blank: true
  
  scope :for, -> (vehicle_id) { where(vehicle_id: vehicle_id) }
  scope :complete, -> { where("compliance_date IS NOT NULL") }
  scope :incomplete, -> { where("compliance_date IS NULL") }
  
  # TODO
  # scope :overdue, -> (as_of: Date.current) { incomplete.where("due_date < ?", as_of) }
  # scope :due_soon, -> (as_of: Date.current, through: nil) { incomplete.where(due_date: as_of..(through || as_of + 6.days)) }
  # scope :default_order, -> { order("due_date DESC") }
  
  def complete!
    update_attribute :compliance_date, Date.current
  end
  
  def complete?
    compliance_date.present?
  end
  
  def vehicle_odometer_reading
    vehicle.last_odometer_reading
  end
  
  private
  
  def due_date_required?
    [:both, :date].include? due_type.try(:to_sym)
  end
  
  def due_mileage_required?
    [:both, :mileage].include? due_type.try(:to_sym)
  end
end

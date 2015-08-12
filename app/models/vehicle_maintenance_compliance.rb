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
  scope :complete, -> { where().not(compliance_date: nil) }
  scope :incomplete, -> { where(compliance_date: nil) }
  scope :default_order, -> { order("due_date IS NOT NULL, due_date DESC, due_mileage DESC") }
  
  # NOTE These 2 scopes rely on data from vehicles and runs
  # RADAR change to pure SQL if this routinely operates on large sets
  scope :overdue, -> (as_of: Date.current) { where(id: incomplete.select{ |r| r.overdue?(as_of: as_of) }.collect(&:id)) }
  scope :due_soon, -> (as_of: Date.current, within_mileage: 500) { where(id: incomplete.select{ |r| r.overdue?(as_of: as_of, mileage: (r.vehicle_odometer_reading - within_mileage)) }.collect(&:id)) }
  
  def complete!
    update_attribute :compliance_date, Date.current
  end
  
  def complete?
    compliance_date.present?
  end
  
  def overdue?(as_of: Date.current, mileage: vehicle_odometer_reading)
    case due_type.to_sym
    when :date
      is_after_due_date? as_of
    when :mileage
      is_over_due_mileage? mileage
    when :both
      is_after_due_date?(as_of) && is_over_due_mileage?(mileage)
    end
  end
  
  def vehicle_odometer_reading
    vehicle.last_odometer_reading
  end
  
  private
  
  def is_after_due_date?(as_of)
    if as_of.is_a? Range
      logger.debug "Does #{as_of.first}..#{as_of.last} include #{due_date}?"
      as_of.include? due_date
    else
      logger.debug "Is #{as_of} > #{due_date}?"
      as_of > due_date
    end
  end
  
  def is_over_due_mileage?(mileage)
    if mileage.is_a? Range
      logger.debug "Does #{mileage.first}..#{mileage.last} include #{due_mileage}?"
      mileage.include? due_mileage
    else
      logger.debug "Is #{mileage} > #{due_mileage}?"
      mileage > due_mileage
    end
  end
  
  def due_date_required?
    [:both, :date].include? due_type.try(:to_sym)
  end
  
  def due_mileage_required?
    [:both, :mileage].include? due_type.try(:to_sym)
  end
end

class DriverCompliance < ActiveRecord::Base
  before_destroy :prevent_destroy_on_recurring_events
  
  belongs_to :driver
  belongs_to :recurring_driver_compliance
  
  validates_presence_of :driver, :event
  validates_date :due_date
  validates_date :compliance_date, on_or_before: -> { Date.current }, allow_blank: true
  validate :prevent_updates_on_recurring_events, on: :update
  
  scope :for, -> (driver_id) { where(driver_id: driver_id) }
  scope :incomplete, -> { where("compliance_date IS NULL") }
  scope :overdue, -> (as_of: Date.current) { incomplete.where("due_date < ?", as_of) }
  scope :due_soon, -> (as_of: Date.current, through: nil) { incomplete.where(due_date: as_of..(through || as_of + 6.days)) }
  scope :default_order, -> { order("due_date DESC") }

  private
  
  def is_recurring?
    recurring_driver_compliance.present?
  end

  def prevent_destroy_on_recurring_events
    errors.add(:base, "Automatically generated events cannot be deleted") if is_recurring?
    errors.empty?
  end

  # Only allow updating the compliance_date and notes fields if the record is
  # associated with a RecurringDriverCompliance record
  def prevent_updates_on_recurring_events
    if is_recurring?
      changed_attributes.except(:compliance_date, :notes).keys.each do |key|
        errors.add(key, "cannot be modified on an automatically generated event")
      end
    end
  end
end

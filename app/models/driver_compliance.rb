class DriverCompliance < ActiveRecord::Base
  before_destroy :prevent_destroy_on_recurring_events
  
  belongs_to :driver, inverse_of: :driver_compliances
  belongs_to :recurring_driver_compliance, inverse_of: :driver_compliances
  
  validates_presence_of :driver, :event
  validates_date :due_date
  validates_date :compliance_date, on_or_before: -> { Date.current }, allow_blank: true
  validate :limit_updates_on_recurring_events, on: :update
  
  scope :for, -> (driver_id) { where(driver_id: driver_id) }
  scope :complete, -> { where("compliance_date IS NOT NULL") }
  scope :incomplete, -> { where("compliance_date IS NULL") }
  scope :overdue, -> (as_of: Date.current) { incomplete.where("due_date < ?", as_of) }
  scope :due_soon, -> (as_of: Date.current, through: nil) { incomplete.where(due_date: as_of..(through || as_of + 6.days)) }
  scope :default_order, -> { order("due_date DESC") }

  def complete!
    update_attribute :compliance_date, Date.current
  end
  
  def complete?
    compliance_date.present?
  end
  
  private
  
  def is_recurring?
    recurring_driver_compliance.present?
  end

  # Prevent destruction when there is an associated RecurringDriverCompliance.
  # Note that because of this we specify :delete_all in the Driver model for
  # the :driver_compliances association, so callbacks on this model are not
  # fired during a cascade delete from a driver!
  def prevent_destroy_on_recurring_events
    errors.add(:base, "Automatically generated events cannot be deleted") if is_recurring?
    errors.empty?
  end

  # Only allow updating the compliance_date field if the record is associated 
  # with a RecurringDriverCompliance record
  def limit_updates_on_recurring_events
    if is_recurring?
      changed_attributes.except(:compliance_date).keys.each do |key|
        errors.add(key, "cannot be modified on an automatically generated event")
      end
    end
  end
end

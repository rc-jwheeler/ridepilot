class DriverCompliance < ActiveRecord::Base
  belongs_to :driver, inverse_of: :driver_compliances
  
  validates_presence_of :driver, :event
  validates_date :due_date
  validates_date :compliance_date, on_or_before: -> { Date.current }, allow_blank: true
  
  scope :for, -> (driver_id) { where(driver_id: driver_id) }
  scope :overdue, -> (as_of: Date.current) { where('due_date < ? AND compliance_date IS NULL', as_of) }
  scope :default_order, -> { order("due_date DESC") }
  
  def self.due_soon(as_of: Date.current, through: nil)
    through ||=  as_of + 6.days
    where(due_date: as_of..through, compliance_date: nil)
  end
  
  def complete!
    update_attribute :compliance_date, Date.current
  end
end

class DriverCompliance < ActiveRecord::Base
  belongs_to :driver, inverse_of: :driver_compliances
  
  validates_presence_of :driver, :event
  validates_date :due_date
  validates_date :compliance_date, on_or_after: :due_date, on_or_before: -> { Date.current }, allow_blank: true
  
  def complete!
    update_attribute :compliance_date, Date.current
  end
end

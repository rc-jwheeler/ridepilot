class DriverCompliance < ActiveRecord::Base
  belongs_to :driver, inverse_of: :driver_histories
  
  validates_presence_of :driver, :event
  validates_date :due_date
  validates_date :compliance_date, on_or_after: :due_date, on_or_before: -> { Date.current }, allow_blank: true
end

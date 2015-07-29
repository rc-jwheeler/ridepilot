class DriverHistory < ActiveRecord::Base
  belongs_to :driver, inverse_of: :driver_histories
  
  validates_presence_of :driver, :event
  validates_date :event_date, on_or_before: -> { Date.current }
end
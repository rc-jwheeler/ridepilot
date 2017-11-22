class OperatingHour < ActiveRecord::Base  
  include OperatingHourCore
  validates_presence_of :day_of_week
  default_scope -> { order :day_of_week }
end

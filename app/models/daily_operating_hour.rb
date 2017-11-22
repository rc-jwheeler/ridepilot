class DailyOperatingHour < ActiveRecord::Base
  include OperatingHourCore
  validates_presence_of :date
  default_scope -> { order :date }
end

class RecurringDriverCompliance < ActiveRecord::Base
  include RecurringComplianceEventScheduler
  creates_occurrences_for :driver_compliances, on: :drivers
  
  validates :recurrence_schedule, presence: true
  validates :recurrence_frequency, presence: true
end

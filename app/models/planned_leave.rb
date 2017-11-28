class PlannedLeave < ActiveRecord::Base
  belongs_to :leavable, polymorphic: true

  scope :leave_on_date, -> (date) { where("(start_date is NULL or start_date > ?) and (end_date is NULL or end_date < ?)", date, date) }
end

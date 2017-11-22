class PlannedLeave < ActiveRecord::Base
  belongs_to :leavable, polymorphic: true
end

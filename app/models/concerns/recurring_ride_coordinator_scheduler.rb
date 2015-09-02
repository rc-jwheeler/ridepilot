require 'active_support/concern'

module RecurringRideCoordinatorScheduler
  extend ActiveSupport::Concern
  include ScheduleAttributes

  NON_TRIP_ATTRIBUTES = %w(id recurrence schedule_yaml created_at updated_at lock_version)

  included do
  end
  
  def instantiate!
    raise "Must be defined by including model!"
  end
  
  module ClassMethods
    # Create occurrences from all schedulers. This method is idempotent.
    def generate!
      for scheduler in self.all
        scheduler.instantiate!
      end
    end

    def trip_attributes  
      attribute_names - NON_TRIP_ATTRIBUTES
    end
  end
end

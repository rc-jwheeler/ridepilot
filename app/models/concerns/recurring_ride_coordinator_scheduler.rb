require 'active_support/concern'

module RecurringRideCoordinatorScheduler
  extend ActiveSupport::Concern
  include ScheduleAttributes

  NON_TRIP_ATTRIBUTES = %w(id recurrence schedule_yaml created_at updated_at lock_version)

  included do
  end
  
  module ClassMethods
    def trip_attributes  
      attribute_names - NON_TRIP_ATTRIBUTES
    end
  end
end

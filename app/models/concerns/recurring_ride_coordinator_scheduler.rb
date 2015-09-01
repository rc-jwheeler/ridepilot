require 'active_support/concern'

module RecurringRideCoordinatorScheduler
  extend ActiveSupport::Concern
  include ScheduleAttributes

  included do
  end
  
  module ClassMethods
  end
end

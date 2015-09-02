require 'active_support/concern'

module RecurringRideCoordinator
  extend ActiveSupport::Concern

  DAYS_OF_WEEK = %w{monday tuesday wednesday thursday friday saturday sunday}

  included do
    DAYS_OF_WEEK.each do |day|
      define_method "repeats_#{day}s=" do |value|
        instance_variable_set "@repeats_#{day}s", (value == "1" || value == true)
      end

      define_method "repeats_#{day}s" do
        if instance_variable_get("@repeats_#{day}s").nil?
          if repeating_trip.present?
            # TODO make repeating_trip including-class agnostic
            instance_variable_set "@repeats_#{day}s", repeating_trip.schedule_attributes.send(day) == 1
          else
            instance_variable_set "@repeats_#{day}s", false 
          end
        else
          instance_variable_get("@repeats_#{day}s")
        end
      end
    end
  end
  
  module ClassMethods
  end
end

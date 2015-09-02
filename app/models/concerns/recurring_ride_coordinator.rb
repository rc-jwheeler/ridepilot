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
  
  def repetition_driver_id=(value)
    @repetition_driver_id = (value.blank? ? nil : value.to_i)
  end

  def repetition_driver_id
    if @repetition_driver_id.nil?
      # TODO make repeating_trip including-class agnostic
      @repetition_driver_id = repeating_trip.try :driver_id
    else
      @repetition_driver_id
    end
  end

  def repetition_vehicle_id=(value)
    @repetition_vehicle_id = (value.blank? ? nil : value.to_i)
  end

  def repetition_vehicle_id
    if @repetition_vehicle_id.nil?
      # TODO make repeating_trip including-class agnostic
      @repetition_vehicle_id = repeating_trip.try :vehicle_id
    else
      @repetition_vehicle_id
    end
  end

  def repetition_customer_informed=(value)
    @repetition_customer_informed = (value == "1" || value == true)
  end

  def repetition_customer_informed
    if @repetition_customer_informed.nil?
      # TODO make repeating_trip including-class agnostic
      @repetition_customer_informed = repeating_trip.try :customer_informed
    else
      @repetition_customer_informed
    end
  end

  def repetition_interval=(value)
    @repetition_interval = value.to_i
  end

  def repetition_interval
    if @repetition_interval.nil?
      # TODO make repeating_trip including-class agnostic
      if repeating_trip.present?
        @repetition_interval = repeating_trip.schedule_attributes.interval 
      else
        1
      end
    else
      @repetition_interval
    end
  end

  def is_repeating_trip?
    (repetition_interval || 0) > 0 &&
    (
      repeats_mondays    ||
      repeats_tuesdays   ||
      repeats_wednesdays ||
      repeats_thursdays  ||
      repeats_fridays    ||
      repeats_saturdays  ||
      repeats_sundays
    )
  end
  
  module ClassMethods
  end
end

require 'active_support/concern'

module RecurringRideCoordinator
  extend ActiveSupport::Concern

  DAYS_OF_WEEK = %w{monday tuesday wednesday thursday friday saturday sunday}

  included do
    attr_accessor :via_recurring_ride_coordinator_scheduler

    before_create :create_recurring_ride_coordinator
    before_update :update_recurring_ride_coordinator
    after_save    :instantiate_recurring_ride_coordinators

    DAYS_OF_WEEK.each do |day|
      define_method "repeats_#{day}s=" do |value|
        instance_variable_set "@repeats_#{day}s", (value == "1" || value == true)
      end

      define_method "repeats_#{day}s" do
        if instance_variable_get("@repeats_#{day}s").nil?
          if send(self.class.occurrence_scheduler_association).present?
            instance_variable_set "@repeats_#{day}s", send(self.class.occurrence_scheduler_association).schedule_attributes.send(day) == 1
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
    attr_reader :occurrence_scheduler_association
    attr_reader :occurrence_scheduler_association_id
    attr_reader :occurrence_scheduler_class

    private

    # Setup method for including class
    def schedules_occurrences_with(association, class_name: nil)
      @occurrence_scheduler_association = association
      @occurrence_scheduler_association_id = "#{association}_id"
      @occurrence_scheduler_class = if class_name.present?
        if class_name.is_a? Class
          class_name
        else
          class_name.to_s.camelize.constantize
        end
      else
        association.to_s.singularize.camelize.constantize
      end

      belongs_to @occurrence_scheduler_association

      scope :repeating_based_on, -> (scheduler) { where(@occurrence_scheduler_association_id => scheduler.id) }
    end
  end
  
  def repetition_driver_id=(value)
    @repetition_driver_id = (value.blank? ? nil : value.to_i)
  end

  def repetition_driver_id
    if @repetition_driver_id.nil?
      @repetition_driver_id = send(self.class.occurrence_scheduler_association).try :driver_id
    else
      @repetition_driver_id
    end
  end

  def repetition_vehicle_id=(value)
    @repetition_vehicle_id = (value.blank? ? nil : value.to_i)
  end

  def repetition_vehicle_id
    if @repetition_vehicle_id.nil?
      @repetition_vehicle_id = send(self.class.occurrence_scheduler_association).try :vehicle_id
    else
      @repetition_vehicle_id
    end
  end

  def repetition_interval=(value)
    @repetition_interval = value.to_i
  end

  def repetition_interval
    if @repetition_interval.nil?
      if send(self.class.occurrence_scheduler_association).present?
        @repetition_interval = send(self.class.occurrence_scheduler_association).schedule_attributes.interval 
      else
        1
      end
    else
      @repetition_interval
    end
  end

  def is_recurring_ride_coordinator?
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
  
  private
  
  def create_recurring_ride_coordinator
    if is_recurring_ride_coordinator? && !via_recurring_ride_coordinator_scheduler
      self.send("#{self.class.occurrence_scheduler_association}=", self.class.occurrence_scheduler_class.create!(recurring_ride_coordinator_attributes))
    end
  end

  def update_recurring_ride_coordinator
    if is_recurring_ride_coordinator? 
      # This is a repeating ride coordinator, so we need to edit both the 
      # scheduler and the occurrences for today
      if send(self.class.occurrence_scheduler_association).blank?
        create_recurring_ride_coordinator
      else
        send(self.class.occurrence_scheduler_association).attributes = recurring_ride_coordinator_attributes
        if send(self.class.occurrence_scheduler_association).changed?
          send(self.class.occurrence_scheduler_association).save!
          destroy_future_recurring_ride_coordinators
        end
      end
    elsif !is_recurring_ride_coordinator? && send(self.class.occurrence_scheduler_association).present?
      destroy_future_recurring_ride_coordinators
      unlink_past_recurring_ride_coordinators
      rt = send(self.class.occurrence_scheduler_association)
      self.send("#{self.class.occurrence_scheduler_association_id}=", nil)
      rt.destroy
    end
  end

  def instantiate_recurring_ride_coordinators
    send(self.class.occurrence_scheduler_association).instantiate! if !send(self.class.occurrence_scheduler_association_id).nil? && !via_recurring_ride_coordinator_scheduler
  end

  def destroy_future_recurring_ride_coordinators
    # Be sure not delete occurrences that have already happened.
    if pickup_time < Time.now 
      self.class.repeating_based_on(send(self.class.occurrence_scheduler_association)).after_today.not_called_back.destroy_all
    else 
      self.class.repeating_based_on(send(self.class.occurrence_scheduler_association)).after(pickup_time).not_called_back.destroy_all
    end
  end

  def unlink_past_recurring_ride_coordinators
    if pickup_time < Time.now 
      self.class.repeating_based_on(send(self.class.occurrence_scheduler_association)).today_and_prior.update_all "#{self.class.occurrence_scheduler_association_id} = NULL"
    else 
      self.class.repeating_based_on(send(self.class.occurrence_scheduler_association)).prior_to(pickup_time).update_all "#{self.class.occurrence_scheduler_association_id} = NULL"
    end
  end

  def recurring_ride_coordinator_attributes
    attrs = {}
    self.class.occurrence_scheduler_class.ride_coordinator_attributes.each {|attr| attrs[attr] = self.send(attr) }
    attrs['driver_id'] = repetition_driver_id
    attrs['vehicle_id'] = repetition_vehicle_id
    attrs['customer_informed'] = repetition_customer_informed
    attrs['schedule_attributes'] = {
      repeat:        1,
      interval_unit: "week", 
      start_date:    pickup_time.to_date.to_s,
      interval:      repetition_interval, 
      monday:        repeats_mondays    ? 1 : 0,
      tuesday:       repeats_tuesdays   ? 1 : 0,
      wednesday:     repeats_wednesdays ? 1 : 0,
      thursday:      repeats_thursdays  ? 1 : 0,
      friday:        repeats_fridays    ? 1 : 0,
      saturday:      repeats_saturdays  ? 1 : 0,
      sunday:        repeats_sundays    ? 1 : 0
    }
    attrs
  end  
end

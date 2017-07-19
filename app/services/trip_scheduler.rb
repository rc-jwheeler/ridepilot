class TripScheduler
  attr_reader :trip, :run, :errors

  def initialize(trip_id, run_id)
    @trip = Trip.find_by_id(trip_id)
    @run = get_run(run_id.to_i)
    @errors = []
  end

  def execute
    return if !@trip || !@run 

    return if @trip.adjusted_run_id == @run.id

    case @run.id
    when Run::UNSCHEDULED_RUN_ID
      unschedule
    when Run::CAB_RUN_ID 
      schedule_to_cab
    else
      schedule_to_run
    end
  end

  private

  def get_run(run_id)
    case run_id
    when Run::CAB_RUN_ID 
      Run.fake_cab_run
    when Run::UNSCHEDULED_RUN_ID
      Run.fake_unscheduled_run
    else
      Run.find_by_id(run_id)
    end
  end

  def unschedule
    @trip.update_attribute :cab, false
    @trip.update_attribute :run, nil
  end

  def schedule_to_cab
    @trip.update_attribute :cab, true
    @trip.update_attribute :run, nil
  end

  def schedule_to_run
    if !validate_time_availability
      errors << TranslationEngine.translate_text(:not_fit_in_run_schedule)
    end

    if !validate_vehicle_availability 
      errors << TranslationEngine.translate_text(:vehicle_unavailable)
    end

    if !validate_driver_availability 
      errors << TranslationEngine.translate_text(:driver_unavailable)
    end

    if errors.empty?
      @trip.cab = false
      @trip.run = @run
      @trip.save(validate: false)
    end

  end

  # run avaiability validations

  # run can hold a trip
  def validate_time_availability
    run_start_time = @run.scheduled_start_time
    run_end_time = @run.scheduled_end_time

    if run_start_time && run_end_time
      (to_utc_time_only(@trip.pickup_time) >= to_utc_time_only(run_start_time)) && 
      (@trip.appointment_time.nil? || to_utc_time_only(@trip.appointment_time) <= to_utc_time_only(run_end_time))
    else
      true
    end
  end

  def validate_vehicle_availability
    @run.vehicle && @run.vehicle.active
  end

  def validate_driver_availability
    @run.driver && @run.driver.active
  end

  def response_as_json(is_success, error_text = '')
    {
      success: is_success,
      message: error_text || '',
      trip_event_json: is_success ? @trip.as_run_event_json : nil
    }
  end

  private

  def to_utc_time_only(time)
    time.utc.strftime("%H%M%S%N") if time
  end

end
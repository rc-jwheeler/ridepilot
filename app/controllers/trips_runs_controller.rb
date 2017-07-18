class TripsRunsController < ApplicationController
  before_action :authorization

  def index
    Date.beginning_of_week= :sunday
    filters_hash = runs_trips_params || {}
    update_sessions(filters_hash.except(:start, :end))

    # by default, select all trip results
    unless session[:trip_result_id].present?
      session[:trip_result_id] = [TripResult::UNSCHEDULED_ID, TripResult::SHOW_ALL_ID] + TripResult.pluck(:id).uniq
    end
    
    query_trips_runs
    
    @run_trip_day    = Utility.new.parse_date(session[:run_trip_day])

    base_runs = @runs
    base_runs = add_cab_run(base_runs) if current_provider.try(:cab_enabled?)

    @runs_for_dropdown = add_unscheduled_run(base_runs).collect {|r| [r.label, r.id]}

    respond_to do |format|
      format.html
    end
  end

  def schedule
    @run = Run.find_by_id params[:run_id]
    @prev_run = Run.find_by_id(params[:prev_run_id]) if params[:prev_run_id].present?
    if @run
      @scheduler = TripScheduler.new(params[:trip_id], params[:run_id])
      @scheduler.execute

      query_trips_runs
    end
  end

  def unschedule
    @prev_run = Run.find_by_id(params[:prev_run_id])
    @target_trips = Trip.where(id: params[:trip_ids].split(','))
    if @target_trips.any?
      case params[:run_id]
      when Run::STANDBY_RUN_ID
        #TODO: standby
      when Run::CAB_RUN_ID
        @target_trips.update_all(cab: true)
      end

      @target_trips.update_all(run_id: nil)

      query_trips_runs
    end
  end

  # Ajax to update Run filter given a new date
  def runs_by_date
    @runs = Run.for_date(Utility.new.parse_date(params[:run_trip_day])).order(:name)
  end

  def run_trips
    @run = Run.find_by_id params[:run_id]
  end
  
  private

  def authorization
    authorize! :read, Run, :provider_id => current_provider_id
    authorize! :read, Trip, :provider_id => current_provider_id
  end

  def query_trips_runs
    filters_hash = runs_trips_params || {}

    @runs = Run.for_provider(current_provider_id).order(:name, :date, :actual_start_time)
    @runs = @runs.where(id: filters_hash[:run_id]) unless filters_hash[:run_id].blank?
    filter_runs

    @trips = Trip.has_scheduled_time.for_provider(current_provider_id).includes(:customer, :pickup_address, :run)
    .references(:customer, :pickup_address, :run).order(:pickup_time)
    # Exclude trips with following result codes from trips-runs page
    exclude_trip_result_ids = TripResult.non_dispatchable_result_ids
    @trips = @trips.where("trip_result_id is NULL or trip_result_id not in (?)", exclude_trip_result_ids)
    filter_trips

    @unassigned_trips = @trips.where("cab = ? and run_id is NULL", false)
    @standby_trips = Trip.none
  end

  def filter_trips
    trip_filter = TripFilter.new(@trips, trip_sessions)
    @trips = trip_filter.filter!
  end

  def filter_runs
    run_filter = RunFilter.new(@runs, run_sessions)
    @runs = run_filter.filter!
  end

  def runs_trips_params
    raw_params = params[:run_trip_filters] || {}
    
    if params[:run_trip_filters]
      raw_params[:run_trip_day] = Date.today.in_time_zone.to_i if raw_params[:run_trip_day].blank?
    else
      if session[:run_trip_day]
        raw_params[:run_trip_day] = Utility.new.parse_date(session[:run_trip_day]).try(:to_i) 
      else
        raw_params[:run_trip_day] = Date.today.in_time_zone.to_i
      end
    end

    raw_params
  end

  def update_sessions(params = {})
    params.each do |key, val|
      session[key] = val if !val.nil?
    end
  end

  def run_sessions
    {
      start: session[:run_trip_day],
      end: session[:run_trip_day], 
      run_id: session[:run_id], 
      run_result_id: session[:run_result_id]
    }
  end

  def trip_sessions
    {
      start: session[:run_trip_day],
      end: session[:run_trip_day],  
      run_id: session[:run_id], 
      trip_result_id: session[:trip_result_id], 
      status_id: session[:status_id]
    }
  end

  def add_cab_run(runs)
    runs + [Run.fake_cab_run]
  end

  def add_unscheduled_run(runs)
    runs + [Run.fake_unscheduled_run]
  end
end

class TripsRunsController < ApplicationController
  def index
    authorize! :read, Run, :provider_id => current_provider_id
    authorize! :read, Trip, :provider_id => current_provider_id

    Date.beginning_of_week= :sunday

    @runs = Run.for_provider(current_provider_id).includes(:driver, :vehicle).order(:date)
    filter_runs

    @trips = Trip.for_provider(current_provider_id).includes(:customer, :pickup_address, {:run => [:driver, :vehicle]})
    .references(:customer, :pickup_address, {:run => [:driver, :vehicle]}).order(:pickup_time)
    filter_trips
    
    @vehicles        = add_cab(Vehicle.accessible_by(current_ability).where(:provider_id => current_provider_id))
    @drivers         = Driver.active.for_provider current_provider_id
    @run_trip_day    = Time.at(session[:run_trip_day].to_i).to_date

    @runs_json       = @runs.map{ |run|
      as_resource_json(run)
    }.to_json # TODO: sql refactor to improve performance
    @trips_json      = @trips.map(&:as_run_event_json).to_json # TODO: sql refactor to improve performance


    respond_to do |format|
      format.html
    end
  end
  
  private

  def filter_trips
    filters_hash = runs_trips_params || {}
    
    update_sessions(filters_hash.except(:start, :end))

    trip_filter = TripFilter.new(@trips, trip_sessions)
    @trips = trip_filter.filter!
    # need to re-update start&end pickup filters
    # as default values are used if they were not presented initially
    update_sessions({
      run_trip_day: trip_filter.filters[:start]
      })
  end

  def filter_runs
    filters_hash = runs_trips_params || {}
    
    update_sessions(filters_hash.except(:start, :end))

    run_filter = RunFilter.new(@runs, run_sessions)
    @runs = run_filter.filter!
  end

  def runs_trips_params
    raw_params = params[:run_trip_filters]
    if raw_params
      raw_params[:start] = raw_params[:run_trip_day]
      raw_params[:end] = raw_params[:run_trip_day]
      raw_params.except(:run_trip_day)
    end
  end

  def update_sessions(params = {})
    params.each do |key, val|
      session[key] = val if !val.nil?
    end
  end

  def run_sessions
    {
      start: session[:start],
      end: session[:end], 
      driver_id: session[:driver_id], 
      vehicle_id: session[:vehicle_id],
      run_result_id: session[:run_result_id]
    }
  end

  def trip_sessions
    {
      start: session[:start],
      end: session[:end], 
      driver_id: session[:driver_id], 
      vehicle_id: session[:vehicle_id],
      trip_result_id: session[:trip_result_id], 
      status_id: session[:status_id]
    }
  end

  def add_cab(vehicles)
    cab_vehicle = Vehicle.new :name => "Cab"
    cab_vehicle.id = -1
    [cab_vehicle] + vehicles 
  end

  def as_resource_json(run)
    {
      id:   run.id, 
      name: "<a href='#{runs_path}/#{run.id}'>#{run.label}</a>",
      isDate: false
    }
  end
end

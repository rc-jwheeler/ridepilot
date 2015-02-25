class RepeatingTripsController < ApplicationController
  before_action :set_repeating_trip, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @repeating_trips = RepeatingTrip.all
    respond_with(@repeating_trips)
  end

  def show
    respond_with(@repeating_trip)
  end

  def new
    @repeating_trip = RepeatingTrip.new
    respond_with(@repeating_trip)
  end

  def edit
  end

  def create
    @repeating_trip = RepeatingTrip.new(repeating_trip_params)
    @repeating_trip.save
    respond_with(@repeating_trip)
  end

  def update
    @repeating_trip.update(repeating_trip_params)
    respond_with(@repeating_trip)
  end

  def destroy
    @repeating_trip.destroy
    respond_with(@repeating_trip)
  end

  private
    def set_repeating_trip
      @repeating_trip = RepeatingTrip.find(params[:id])
    end

    def repeating_trip_params
      params.require(:repeating_trip).permit(:schedule_yaml, :provider_id, :customer_id, :pickup_time, :appointment_time, :guest_count, :attendant_count, :group_size, :pickup_address_id, :dropoff_address_id, :mobility_id, :funding_source_id, :trip_purpose, :notes, :round_trip, :driver_id, :vehicle_id, :cab, :customer_informed)
    end
end

class VehicleMaintenanceSchedulesController < ApplicationController
  load_and_authorize_resource :vehicle_maintenance_schedule_type
  load_and_authorize_resource :vehicle_maintenance_schedule, through: :vehicle_maintenance_schedule_type, except: [:create]

  respond_to :html, :js

  def index
    @vehicle_maintenance_schedules = @vehicle_maintenance_schedule_type.vehicle_maintenance_schedules.order(:mileage)
  end

  def new
  end

  def create
    @vehicle_maintenance_schedule = VehicleMaintenanceSchedule.new(schedule_params)
    @vehicle_maintenance_schedule.vehicle_maintenance_schedule_type = @vehicle_maintenance_schedule_type
    if @vehicle_maintenance_schedule.save
      respond_to do |format|
        format.js
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @vehicle_maintenance_schedule.update(schedule_params)
      respond_to do |format|
        format.js
      end
    else
      render :edit
    end
  end

  def destroy
    @vehicle_maintenance_schedule.destroy
    respond_to do |format|
      format.js
    end
  end

  private

  def schedule_params
    params.require(:vehicle_maintenance_schedule).permit(:name, :mileage)
  end
end
class VehicleMaintenanceEventsController < ApplicationController
  load_and_authorize_resource

  def index
    redirect_to provider_path(current_user.current_provider)
  end

  def new
    @vehicle_maintenance_event.vehicle_id = params[:vehicle_id]
  end

  def edit; end

  def update
    if @vehicle_maintenance_event.update_attributes(vehicle_maintenance_event_params)
      flash[:notice] = "Vehicle maintenance event updated"
      redirect_to vehicle_path(@vehicle_maintenance_event.vehicle)
    else
      render :action => :edit
    end 
  end

  def create
    @vehicle_maintenance_event.provider = current_user.current_provider
    if @vehicle_maintenance_event.save
      flash[:notice] = "Vehicle maintenance event created"
      redirect_to vehicle_path(@vehicle_maintenance_event.vehicle)
    else
      render :action => :new
    end
  end

  private
  
  def vehicle_maintenance_event_params
    params.require(:vehicle_maintenance_event).permit(:vehicle_id, :reimbursable, :service_date, :invoice_date, :services_performed, :odometer, :vendor_name, :invoice_number, :invoice_amount)
  end
  
end

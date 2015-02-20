class VehiclesController < ApplicationController
  load_and_authorize_resource

  def index
    redirect_to provider_path(current_provider)
  end

  def show; end

  def new; end

  def edit; end

  def update
    if @vehicle.update_attributes(vehicle_params)
      flash[:notice] = "Vehicle updated"
      redirect_to provider_path(current_provider)
    else
      render :action => :edit
    end 
  end

  def create
    @vehicle.provider = current_provider
    if @vehicle.save
      flash[:notice] = "Vehicle created"
      redirect_to provider_path(current_provider)
    else
      render :action => :new
    end
  end

  def destroy
    @vehicle.destroy
    redirect_to provider_path(current_provider)
  end

  private
  
  def vehicle_params
    params.require(:vehicle).permit(:name, :year, :make, :model, :license_plate, :vin, :garaged_location, :active, :default_driver_id, :reportable)
  end
  
end

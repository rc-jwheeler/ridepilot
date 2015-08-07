class VehiclesController < ApplicationController
  load_and_authorize_resource

  def index
    @vehicles = @vehicles.for_provider(current_provider.id)
  end

  def show; end

  def new; end

  def edit; end

  def update
    if @vehicle.update_attributes(vehicle_params)
      redirect_to @vehicle, notice: 'Vehicle was successfully updated.'
    else
      render action: :edit
    end 
  end

  def create
    @vehicle.provider = current_provider
    if @vehicle.save
      redirect_to @vehicle, notice: 'Vehicle was successfully created.'
    else
      render action: :new
    end
  end

  def destroy
    @vehicle.destroy
    redirect_to vehicles_path, notice: 'Vehicle was successfully deleted.'
  end

  private
  
  def vehicle_params
    params.require(:vehicle).permit(:name, :year, :make, :model, :license_plate, :vin, :garaged_location, :active, :default_driver_id, :reportable)
  end
  
end

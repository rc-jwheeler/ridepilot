class VehicleCapacitiesController < ApplicationController
  load_and_authorize_resource :vehicle_type
  load_and_authorize_resource :vehicle_capacity, through: :vehicle_type, except: [:create]

  respond_to :html, :js

  def index
    @vehicle_capacities = @vehicle_type.vehicle_capacities.default_order
  end

  def new
  end

  def create
    @vehicle_capacity = VehicleCapacity.new
    @vehicle_capacity.assign_attributes(capacity_params)
    @vehicle_capacity.vehicle_type = @vehicle_type
    if @vehicle_capacity.save
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
    
    if @vehicle_capacity.update(capacity_params)
      respond_to do |format|
        format.js
      end
    else
      render :edit
    end
  end

  def destroy
    @vehicle_capacity.destroy
    respond_to do |format|
      format.js
    end
  end

  private
  
  def capacity_params
    params.require(:vehicle_capacity).permit(
      :capacity_type_id, 
      :capacity,
      :vehicle_type
    )
  end
  
end

class ProvidersController < ApplicationController
  load_and_authorize_resource

  def new
  end

  def create
    @provider.save!
    redirect_to provider_path(@provider)
  end

  def index
  end
  
  def show
    @unassigned_drivers = Driver.unassigned(@provider)
    @unassigned_vehicles = Vehicle.unassigned(@provider)
  end

  # POST /providers/:id/save_region
  def save_region
    north = params[:region_north].to_f
    west = params[:region_west].to_f
    south = params[:region_south].to_f
    east = params[:region_east].to_f
    if north == 0.0 and west == 0.0
      @provider.region_nw_corner = nil
    else
      @provider.region_nw_corner = Point.from_x_y(west, north)
    end
    if south == 0.0 and east == 0.0
      @provider.region_se_corner = nil
    else
      @provider.region_se_corner = Point.from_x_y(east, south)
    end
    @provider.save!
    redirect_to provider_path(@provider)
  end

  def delete_role
    role = Role.find(params[:role_id])
    user = role.user
    authorize! :edit, role
    role.destroy
    if user.roles.size == 0
      user.destroy
    end
    redirect_to provider_path(params[:provider_id])
  end


  def change_role
    role = Role.find(params[:role][:id])
    authorize! :edit, role
    role.level = params[:role][:level]
    role.save!
    redirect_to provider_path(params[:provider_id])
  end
  
  def change_dispatch    
    @provider.update_attribute :dispatch, params[:dispatch]
    
    redirect_to provider_path(@provider)
  end
  
  def change_scheduling
    @provider.update_attribute :scheduling, params[:scheduling]
    redirect_to provider_path(@provider)
  end

end

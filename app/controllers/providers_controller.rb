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
    array = (0..19).zip(0..19).map()
    @zoom_choices = array.inject({}) do |memo, values|
      memo[values.first.to_s] = values.last.to_s
      memo
    end
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

  # POST /providers/:id/save_viewport
  def save_viewport
    lat = params[:viewport_lat].to_f
    lng = params[:viewport_lng].to_f
    zoom = params[:viewport_zoom].to_i
    if zoom < 0 or zoom >= 20
      flash[:alert] = 'Zoom must be between 0 and 19.'
      redirect_to provider_path(@provider)
    end
    @provider.viewport_zoom = zoom
    if lat == 0.0 and lng == 0.0
      @provider.viewport_center = nil
      @provider.viewport_zoom = nil
    else
      @provider.viewport_center = Point.from_x_y(lng, lat)
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

  def change_allow_trip_entry_from_runs_page
    @provider.update_attribute :allow_trip_entry_from_runs_page, params[:allow_trip_entry_from_runs_page]
    redirect_to provider_path(@provider)
  end

  def change_reimbursement_rates
    reimbursement_params = params.select{|k,v| Provider::REIMBURSEMENT_ATTRIBUTES.include?(k.to_sym)}
    @provider.update_attributes reimbursement_params
    redirect_to provider_path(@provider)
  end
end
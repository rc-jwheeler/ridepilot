class DevicePoolsController < ApplicationController
  load_and_authorize_resource
  
  def new; end
  
  def create
    @device_pool.provider = current_provider
    @device_pool.color    = @device_pool.color.gsub(/#/, "")
    
    if @device_pool.save
      flash[:notice] = "Device pool created"
      redirect_to provider_path(current_provider)
    else
      render :action=>:new
    end
  end
  
  def edit; end
  
  def update
    params[:device_pool][:color] = params[:device_pool][:color].gsub(/#/, "")
    
    @device_pool.update_attributes(params[:device_pool])
    if @device_pool.save
      flash[:notice] = "Device pool updated"
      redirect_to provider_path(current_user.current_provider)
    else
      render :action=>:edit
    end
  end
  
  def destroy
    @device_pool.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = "Device pool deleted"
        redirect_to provider_path(current_user.current_provider)        
      }
      format.js { 
        render :json => { :device_pool => @device_pool.as_json }
      }
    end
  end
end

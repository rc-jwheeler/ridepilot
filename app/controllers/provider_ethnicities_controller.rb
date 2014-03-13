class ProviderEthnicitiesController < ApplicationController
  load_and_authorize_resource :provider_ethnicity

  def index
    redirect_to provider_path(current_provider)
  end

  def show

  end

  def new

  end

  def edit

  end

  def create
    @provider_ethnicity.provider = current_provider
    if @provider_ethnicity.save
      flash[:notice] = "Ethnicity created"
      redirect_to provider_path(current_provider)
    else
      render :action=>:new
    end
  end

  def update
    @provider_ethnicity.provider = current_provider
    if @provider_ethnicity.update_attributes(params[:provider_ethnicity])
      flash[:notice] = "Ethnicity updated"
      redirect_to provider_path(current_provider)
    else
      render :action=>:edit
    end 
  end

  def destroy
    @provider_ethnicity.destroy
    redirect_to provider_path(current_provider)
  end
end

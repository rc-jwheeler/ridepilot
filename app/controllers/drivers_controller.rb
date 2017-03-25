class DriversController < ApplicationController
  load_and_authorize_resource

  def index
    @drivers = @drivers.default_order.for_provider(current_provider.id)
  end

  def show
    prep_edit(readonly: true)
  end

  def new
    @driver.provider = current_provider
    prep_edit
  end

  def edit
    prep_edit
  end

  def update
    @driver.attributes = driver_params
    process_address_geom
    
    if !@driver.is_all_valid?(current_provider_id)
      prep_edit
      render action: :edit
    else
      begin      
        Driver.transaction do
          @driver.save!
          create_or_update_hours!
        end
        redirect_to @driver, notice: 'Driver was successfully updated.'
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.debug e.message
        prep_edit
        render action: :edit
      end
    end
  end

  def create
    process_address_geom
    @driver.provider = current_provider
    if !@driver.is_all_valid?(current_provider_id)
      prep_edit
      render action: :new
    else
      begin
        Driver.transaction do
          @driver.save!
          create_or_update_hours!
        end
        redirect_to @driver, notice: 'Driver was successfully created.'
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.debug e.message
        prep_edit
        render action: :new
      end
    end
  end

  def destroy
    @driver.destroy
    redirect_to drivers_path, notice: 'Driver was successfully deleted.'
  end

  private
  
  def prep_edit(readonly: false)
    @readonly = readonly
    
    @available_users = @driver.provider.users - User.drivers(@driver.provider)
    @available_users << @driver.user if @driver.user
    @available_users = @available_users.sort_by(&:email) 
    
    @hours = @driver.hours_hash

    @start_hours = OperatingHours.available_start_times
    @end_hours = OperatingHours.available_end_times
    
    @driver.address ||= @driver.build_address provider: @driver.provider
  end
  
  def driver_params
    params.require(:driver).permit(
      :active, 
      :paid, 
      :name, 
      :email, 
      :user_id,
      :phone_number,
      :address_attributes => [
        :address,
        :building_name,
        :city,
        :name,
        :provider_id,
        :state,
        :zip,
        :notes
      ]
    )
  end
  
  def create_or_update_hours!
    OperatingHoursProcessor.new(@driver, {
      hours: params[:hours],
      start_hour: params[:start_hour],
      end_hour: params[:end_hour]
      }).process!
  end

  def process_address_geom
    if @driver && @driver.address && params[:lat].present? && params[:lon].present?
      @driver.address.the_geom = RGeo::Geographic.spherical_factory(srid: 4326).point(params[:lon].to_f, params[:lat].to_f)
    end
  end
end

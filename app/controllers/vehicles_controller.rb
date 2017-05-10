class VehiclesController < ApplicationController
  load_and_authorize_resource

  def index
    @vehicles = @vehicles.default_order.for_provider(current_provider.id)
  end

  def show
    @readonly = true
  end

  def new
    @vehicle.provider = current_provider
  end

  def edit; end

  def update
    new_attrs = vehicle_params
    is_garage_address_blank = check_blank_garage_address
    
    if is_garage_address_blank
      prev_garage_address = @vehicle.garage_address
      @vehicle.garage_address_id = nil
      new_attrs.except!(:garage_address_attributes)
    end

    @vehicle.assign_attributes new_attrs

    if @vehicle.garage_address.present?
      @vehicle.garage_address.the_geom = Address.compute_geom(params[:lat], params[:lon])
    end

    if !@vehicle.is_all_valid?(current_provider_id)
      render action: :edit
    else
      begin      
        Driver.transaction do
          @vehicle.save!
          prev_garage_address.destroy if is_garage_address_blank && prev_garage_address.present?
        end
        redirect_to @vehicle, notice: 'Vehicle was successfully updated.'
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.debug e.message
        render action: :edit
      end
    end
  end

  def create
    new_attrs = vehicle_params
    is_garage_address_blank = check_blank_garage_address
    if is_garage_address_blank
      new_attrs.except!(:garage_address_attributes)
    end

    @vehicle.attributes = new_attrs

    if is_garage_address_blank
      @vehicle.garage_address = nil
    elsif @vehicle.garage_address.present?
      @vehicle.garage_address.the_geom = Address.compute_geom(params[:lat], params[:lon])
    end

    @vehicle.provider = current_provider
    if @vehicle.is_all_valid?(current_provider_id) && @vehicle.save
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
    params.require(:vehicle).permit(
      :name, 
      :year, 
      :make, 
      :model, 
      :license_plate, 
      :vin, 
      :active, 
      :reportable, 
      :insurance_coverage_details, 
      :ownership, 
      :responsible_party, 
      :registration_expiration_date, 
      :seating_capacity, 
      :mobility_device_accommodations, 
      :accessibility_equipment, 
      :initial_mileage,
      :garage_phone_number,
      :garage_address_attributes => [
        :provider_id,
        :address,
        :city,
        :state,
        :zip
      ])
  end

   def check_blank_garage_address
    address_params = vehicle_params[:garage_address_attributes]
    is_blank = true
    address_params.keys.each do |key|
      next if key.to_s == 'provider_id'
      unless address_params[key].blank?
        is_blank = false
        break
      end
    end if address_params

    is_blank
  end
  
end

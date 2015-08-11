class VehicleMaintenanceEventsController < ApplicationController
  load_and_authorize_resource :vehicle
  load_and_authorize_resource :vehicle_maintenance_event, through: :vehicle
  
  respond_to :html, :js

  # GET /vehicle_maintenance_events/new
  def new
  end

  # GET /vehicle_maintenance_events/1/edit
  def edit
  end

  # POST /vehicle_maintenance_events
  def create
    if @vehicle_maintenance_event.save
      respond_to do |format|
        format.html { redirect_to @vehicle, notice: 'Vehicle maintenance event was successfully created.' }
        format.js
      end
    else
      render :new
    end 
  end

  # PATCH/PUT /vehicle_maintenance_events/1
  def update
    if @vehicle_maintenance_event.update(vehicle_maintenance_event_params)
      respond_to do |format|
        format.html { redirect_to @vehicle, notice: 'Vehicle maintenance event was successfully updated.' }
        format.js
      end
    else
      render :edit
    end
  end

  # DELETE /vehicle_maintenance_events/1
  def destroy
    @vehicle_maintenance_event.destroy
    respond_to do |format|
      format.html { redirect_to @vehicle, notice: 'Vehicle maintenance event was successfully destroyed.' }
      format.js
    end
  end

  private
  
  def vehicle_maintenance_event_params
    params.require(:vehicle_maintenance_event).permit(:vehicle_id, :reimbursable, :service_date, :invoice_date, :services_performed, :odometer, :vendor_name, :invoice_number, :invoice_amount)
  end
  
end

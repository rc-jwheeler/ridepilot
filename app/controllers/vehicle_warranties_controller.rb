class VehicleWarrantiesController < ApplicationController
  load_and_authorize_resource :vehicle
  load_and_authorize_resource :vehicle_warranty, through: :vehicle
  
  respond_to :html, :js

  # GET /vehicle_warranties/new
  def new
  end

  # GET /vehicle_warranties/1/edit
  def edit
  end

  # POST /vehicle_warranties
  def create
    if @vehicle_warranty.save
      respond_to do |format|
        format.html { redirect_to @vehicle, notice: 'Vehicle warranty was successfully created.' }
        format.js
      end
    else
      render :new
    end
  end

  # PATCH/PUT /vehicle_warranties/1
  def update
    if @vehicle_warranty.update(vehicle_warranty_params)
      respond_to do |format|
        format.html { redirect_to @vehicle, notice: 'Vehicle warranty was successfully updated.' }
        format.js
      end
    else
      render :edit
    end
  end

  # DELETE /vehicle_warranties/1
  def destroy
    @vehicle_warranty.destroy
    respond_to do |format|
      format.html { redirect_to @vehicle, notice: 'Vehicle warranty was successfully destroyed.' }
      format.js
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def vehicle_warranty_params
    params.require(:vehicle_warranty).permit(:description, :notes, :expiration_date)
  end
end

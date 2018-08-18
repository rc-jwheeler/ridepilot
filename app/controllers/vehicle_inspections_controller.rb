class VehicleInspectionsController < ApplicationController
  
  respond_to :html, :js

  def mark_flagged
    if params[:vehicle_inspection]
      insp = VehicleInspection.find_by_id(params[:id])
      if insp
        insp.flagged = params[:vehicle_inspection][:flagged]
        insp.save(validate: false)
      end
    end

    render json: {}
  end

  def mark_mechanical
    if params[:vehicle_inspection]
      insp = VehicleInspection.find_by_id(params[:id])
      if insp
        insp.mechanical = params[:vehicle_inspection][:mechanical]
        insp.save(validate: false)
      end
    end

    render json: {}
  end
end
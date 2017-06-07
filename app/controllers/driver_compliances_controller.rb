class DriverCompliancesController < ApplicationController
  load_and_authorize_resource :driver
  load_and_authorize_resource :driver_compliance, through: :driver
  
  respond_to :html, :js

  def index
    @driver_compliances = @driver.driver_compliances
    @readonly = params[:readonly] == 'true'

    if params[:show_past] != 'true'
      @driver_compliances = @driver_compliances.incomplete
    end

    if params[:legal] != 'true'
      @driver_compliances = @driver_compliances.non_legal
    else
      @driver_compliances = @driver_compliances.legal
    end
  end

  # GET /driver_compliances/new
  def new
    prep_edit
    
    unless params["driver_requirement_template_id"].blank?
      @driver_compliance.driver_requirement_template_id = params["driver_requirement_template_id"]
      @driver_compliance.event = @driver_compliance.driver_requirement_template.try(:name)
    end
  end

  # GET /driver_compliances/1/edit
  def edit
    prep_edit
  end

  # POST /driver_compliances
  def create
    if @driver_compliance.save
      respond_to do |format|
        format.html { redirect_to @driver, notice: 'Driver compliance was successfully created.' }
        format.js
      end
    else
      prep_edit
      render :new
    end
  end

  # PATCH/PUT /driver_compliances/1
  def update
    was_incomplete = !@driver_compliance.complete?
    if @driver_compliance.update(driver_compliance_params)
      @is_newly_completed = was_incomplete && @driver_compliance.complete?
      respond_to do |format|
        format.html { redirect_to @driver, notice: 'Driver compliance was successfully updated.' }
        format.js
      end
    else
      prep_edit
      render :edit
    end
  end

  # DELETE /driver_compliances/1
  def destroy
    @driver_compliance.destroy
    respond_to do |format|
      format.html { redirect_to @driver, notice: 'Driver compliance was successfully destroyed.' }
      format.js
    end
  end

  private
  
  def prep_edit
    @driver_compliance.document_associations.build
  end

  def driver_compliance_params
    params.require(:driver_compliance).permit(:event, :notes, :due_date, :compliance_date, :legal, :driver_requirement_template_id, document_associations_attributes: [:id, :document_id, :_destroy])
  end
end

class DriverHistoriesController < ApplicationController
  load_and_authorize_resource :driver
  before_action :load_driver_history
  
  respond_to :html, :js

  # GET /driver_histories/new
  def new
  end

  # GET /driver_histories/1/edit
  def edit
  end

  # POST /driver_histories
  def create
    params = build_new_documents(driver_history_params)
    @driver_history.assign_attributes(params)
    
    if @driver_history.save
      respond_to do |format|
        format.html { redirect_to @driver, notice: 'Driver history was successfully created.' }
        format.js
      end
    else
      render :new
    end
  end

  # PATCH/PUT /driver_histories/1
  def update
    params = build_new_documents(driver_history_params)
        
    if @driver_history.update(params)
      respond_to do |format|
        format.html { redirect_to @driver, notice: 'Driver history was successfully updated.' }
        format.js
      end
    else
      render :edit
    end
  end

  # DELETE /driver_histories/1
  def destroy
    @driver_history.destroy
    respond_to do |format|
      format.html { redirect_to @driver, notice: 'Driver history was successfully destroyed.' }
      format.js
    end
  end

  private
  
  def load_driver_history
    @driver_history = DriverHistory.find_by_id(params[:id]) || @driver.driver_histories.build
  end
  
  # Builds new associated documents from params
  def build_new_documents(params)
    # Build new documents as appropriate
    params[:documents_attributes].each do |i, doc|
      unless doc[:id].present?
        if doc[:document].present? && doc[:description].present? && doc[:_destroy].to_i.zero?      
          @driver_history.build_document(
            document: doc[:document], 
            description: doc[:description]
          )
        end
        params[:documents_attributes].delete(i)
      end
    end
    
    return params
  end

  def driver_history_params
    params.require(:driver_history).permit(
      :event, 
      :notes, 
      :event_date,
      documents_attributes: [:id, :document, :description, :_destroy]
    )
  end
end

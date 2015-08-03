class RecurringDriverCompliancesController < ApplicationController
  load_and_authorize_resource skip: :preview_schedule
  
  before_filter :prep_form, except: [:index, :show, :destroy, :preview_schedule]
  
  # GET /recurring_driver_compliances
  def index
    # Limit what super admins see on the index
    @recurring_driver_compliances = @recurring_driver_compliances.where(provider: current_provider)
  end

  # GET /recurring_driver_compliances/1
  def show
  end

  # GET /recurring_driver_compliances/new
  def new
  end

  # GET /recurring_driver_compliances/1/edit
  def edit
  end

  # POST /recurring_driver_compliances
  def create
    @recurring_driver_compliance.provider = current_provider
    if @recurring_driver_compliance.save
      redirect_to @recurring_driver_compliance, notice: 'Recurring driver compliance was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /recurring_driver_compliances/1
  def update
    if @recurring_driver_compliance.update(recurring_driver_compliance_params)
      redirect_to @recurring_driver_compliance, notice: 'Recurring driver compliance was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /recurring_driver_compliances/1
  def destroy
    @recurring_driver_compliance.destroy
    redirect_to recurring_driver_compliances_url, notice: 'Recurring driver compliance was successfully destroyed.'
  end
  
  # GET /recurring_driver_compliances/preview_schedule
  def preview_schedule
    @recurring_driver_compliance = RecurringDriverCompliance.new recurring_driver_compliance_params
    if @recurring_driver_compliance.compliance_date_based_scheduling?
      @occurrence_dates = [@recurring_driver_compliance.start_date]
    else
      @occurrence_dates = RecurringDriverCompliance.occurrence_dates_on_schedule_in_range @recurring_driver_compliance, range_start_date: Date.current, range_end_date: (@recurring_driver_compliance.start_date + (@recurring_driver_compliance.recurrence_frequency * 6).send(@recurring_driver_compliance.recurrence_schedule))
    end
    
    render :json => @occurrence_dates.collect{ |date| date.strftime("%A, %b %d, %Y") }
  end

  private

  # Only allow a trusted parameter "white list" through.
  def recurring_driver_compliance_params
    params.require(:recurring_driver_compliance).permit(
      :event_name,
      :event_notes,
      :recurrence_schedule,
      :recurrence_frequency,
      :recurrence_notes,
      :start_date,
      :future_start_rule,
      :future_start_schedule,
      :future_start_frequency,
      :compliance_date_based_scheduling,
    )
  end
  
  def prep_form
    @readonly = @recurring_driver_compliance.driver_compliances.any?
  end
end

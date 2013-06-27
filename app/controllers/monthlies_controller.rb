class MonthliesController < ApplicationController
  load_and_authorize_resource
  before_filter :prep_edit

  def new; end

  def index
    @monthlies = @monthlies.order(:start_date)
  end

  def edit; end

  def update
    @monthly.update_attributes(params[:monthly])
    if @monthly.save
      flash[:notice] = "Monthly report updated"
      redirect_to monthlies_path
    else
      render :edit
    end
  end

  def create
    @monthly.provider = current_provider
    if @monthly.save
      flash[:notice] = "Monthly report created"
      redirect_to monthlies_path
    else
      render :new
    end
  end
  
  private
  
  def prep_edit
    @funding_sources = FundingSource.by_provider(current_provider)
  end
end
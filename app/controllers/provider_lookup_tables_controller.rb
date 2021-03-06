class ProviderLookupTablesController < ApplicationController
  load_and_authorize_resource
  before_action :set_lookup_tables
  before_action :set_lookup_table, except: [:index]

  def index
    @first_lookup_table = @lookup_tables.first
    redirect_to provider_lookup_table_path(@first_lookup_table) if @first_lookup_table.present?
  end

  def show
  end

  def add_value
    @item = @lookup_table.add_value(params[:lookup_table], current_provider_id)
    if @item && @item.errors.any?
      flash[:alert] = @item.errors.full_messages.join('. ')
    end
    redirect_to @lookup_table
  end

  def update_value
    @item = @lookup_table.update_value(params[:model_id], params[:lookup_table])
    if @item && @item.errors.any?
      flash[:alert] = @item.errors.full_messages.join('. ')
    end
    redirect_to @lookup_table
  end

  def destroy_value
    @item = @lookup_table.destroy_value(params[:model_id])
    redirect_to @lookup_table
  end

  private

  def set_lookup_tables
    @lookup_tables = ProviderLookupTable.order(:caption)
  end

  def set_lookup_table
    @lookup_table = ProviderLookupTable.find params[:id]
  end

  def redirect_to_show_page
    if @item && !@item.errors.empty?
      flash.now[:alert] = TranslationEngine.translate_text(:operation_failed) + ": "
      flash.now[:alert] += @item.errors.full_messages.join(';')
    end
    redirect_to provider_lookup_table_path(@lookup_table)
  end
end

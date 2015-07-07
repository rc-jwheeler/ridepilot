class LookupTablesController < ApplicationController
  load_and_authorize_resource
  before_action :set_lookup_tables

  def index
    redirect_to lookup_table_path(@lookup_tables.first) if @lookup_tables.first.present?
  end

  def show
    @lookup_table = LookupTable.find params[:id]
    @table_values = @lookup_table.name.constantize.all.order(@lookup_table.value_column_name).pluck(:id, @lookup_table.value_column_name)
  end

  private

  def set_lookup_tables
    @lookup_tables = LookupTable.order(:caption)
  end
end

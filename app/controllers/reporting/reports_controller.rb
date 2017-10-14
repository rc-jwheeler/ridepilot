module Reporting
  class ReportsController < ApplicationController
    include ReportHelper

    before_action :verify_permission

    def index
      @reports = all_report_infos
      
      
    end

    def show
      @reports = all_report_infos
      @report = Report.find(params[:id])
      @is_generic_report = true
      # reset column information
      @report.data_model.reset_column_information

      # find out filter_groups
      @filter_groups = @report.specific_filter_groups.order(:sort_order)
    end

    private

    def verify_permission
      authorize! :access, Report
    end
    
  end
end

class AddRedirectToResultsToReports < ActiveRecord::Migration
  def change
    add_column :reports, :redirect_to_results, :boolean, default: false
  end
end

class AddManifestOrderToRepeatingRuns < ActiveRecord::Migration
  def change
    add_column :repeating_runs, :manifest_order, :text
  end
end

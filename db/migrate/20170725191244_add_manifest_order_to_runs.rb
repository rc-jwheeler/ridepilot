class AddManifestOrderToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :manifest_order, :text
  end
end

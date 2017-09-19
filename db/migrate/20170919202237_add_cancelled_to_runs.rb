class AddCancelledToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :cancelled, :boolean
  end
end

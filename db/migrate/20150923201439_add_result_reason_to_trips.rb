class AddResultReasonToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :result_reason, :text
  end
end

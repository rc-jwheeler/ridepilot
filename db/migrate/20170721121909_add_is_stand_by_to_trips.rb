class AddIsStandByToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :is_stand_by, :boolean
  end
end

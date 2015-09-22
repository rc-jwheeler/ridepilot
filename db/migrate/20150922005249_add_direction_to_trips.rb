class AddDirectionToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :direction, :string, default: :outbound
    remove_column :trips, :round_trip, :boolean
  end
end

class AddDirectionToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :direction, :string, default: :outbound
  end
end

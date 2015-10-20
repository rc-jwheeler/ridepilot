class AddDescriptionToTripResults < ActiveRecord::Migration
  def change
    add_column :trip_results, :description, :string
  end
end

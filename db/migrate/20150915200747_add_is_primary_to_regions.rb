class AddIsPrimaryToRegions < ActiveRecord::Migration
  def change
    add_column :regions, :is_primary, :boolean
  end
end

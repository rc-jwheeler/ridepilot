class ChangeOperatingHoursToPolymorphic < ActiveRecord::Migration
  def change
    rename_column :operating_hours, :driver_id, :operatable_id
  end
end

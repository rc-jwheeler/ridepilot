class AddIndexToOperatingHours < ActiveRecord::Migration
  def change
    add_index :operating_hours, [:operatable_id, :operatable_type]
  end
end

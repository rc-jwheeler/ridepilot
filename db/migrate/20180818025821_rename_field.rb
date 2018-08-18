class RenameField < ActiveRecord::Migration[5.1]
  def change
    rename_column :vehicle_inspections, :mechnical, :mechanical
  end
end

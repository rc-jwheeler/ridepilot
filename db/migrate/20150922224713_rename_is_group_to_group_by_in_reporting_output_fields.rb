class RenameIsGroupToGroupByInReportingOutputFields < ActiveRecord::Migration
  def change
    rename_column :reporting_output_fields, :is_group, :group_by
  end
end

class AddAliasNameToReportingOutputFields < ActiveRecord::Migration
  def change
    add_column :reporting_output_fields, :alias_name, :string
  end
end

class ChangeLookupTableColumnName < ActiveRecord::Migration
  def change
    rename_column :lookup_tables, :model_name, :model_name_str
    rename_column :provider_lookup_tables, :model_name, :model_name_str
  end
end

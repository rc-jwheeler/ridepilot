class RemoveIsProviderSpecificFromLookupTables < ActiveRecord::Migration
  def change
    remove_column :lookup_tables, :is_provider_specific, :boolean
  end
end

class AddAllowTripEntryFromRunsPageToProviders < ActiveRecord::Migration
  def self.up
    add_column :providers, :allow_trip_entry_from_runs_page, :boolean
  end

  def self.down
    remove_column :providers, :allow_trip_entry_from_runs_page
  end
end

class AddAdaEligibleToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :ada_eligible, :boolean
  end

  def self.down
    remove_column :customers, :ada_eligible
  end
end

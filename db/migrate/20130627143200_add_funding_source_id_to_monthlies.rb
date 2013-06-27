class AddFundingSourceIdToMonthlies < ActiveRecord::Migration
  def self.up
    add_column :monthlies, :funding_source_id, :integer
  end

  def self.down
    remove_column :monthlies, :funding_source_id
  end
end

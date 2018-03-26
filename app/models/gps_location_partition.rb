class GpsLocationPartition < ApplicationRecord
  
  after_destroy :destroy_partition

  private

  def destroy_partition
    index_name = self.table_name + "_provider_logtime_idx"
    sql = "DROP INDEX IF EXISTS #{index_name};"
    sql += " DROP TABLE IF EXISTS #{self.table_name}";
      
    ActiveRecord::Base.connection.execute sql

    true
  end

end

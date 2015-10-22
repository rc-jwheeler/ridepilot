class AddDeletedAtToBookingUsers < ActiveRecord::Migration
  def change
    add_column :booking_users, :deleted_at, :datetime
  end
end

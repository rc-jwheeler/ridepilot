class AddUrlToBookingUsers < ActiveRecord::Migration
  def change
    add_column :booking_users, :url, :string
  end
end

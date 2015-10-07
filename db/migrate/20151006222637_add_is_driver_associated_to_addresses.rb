class AddIsDriverAssociatedToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :is_driver_associated, :boolean, default: false
  end
end

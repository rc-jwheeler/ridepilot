class AddMessageToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :message, :text
  end
end

class AddCustomerReferenceToDonations < ActiveRecord::Migration
  def change
    add_reference :donations, :customer, index: true
  end
end

class AddEligibleToCustomerEligibilities < ActiveRecord::Migration
  def change
    add_column :customer_eligibilities, :eligible, :boolean
  end
end

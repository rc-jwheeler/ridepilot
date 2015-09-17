class CustomerAddress < ActiveRecord::Base
  self.table_name = 'addresses_customers'
  belongs_to :customer
  belongs_to :address
end
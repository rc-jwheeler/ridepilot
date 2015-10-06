class AddPhoneNumberToDrivers < ActiveRecord::Migration
  def change
    add_column :drivers, :phone_number, :string
  end
end

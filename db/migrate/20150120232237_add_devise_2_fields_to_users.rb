class AddDevise2FieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :unconfirmed_email, :string
    add_column :users, :reset_password_sent_at, :datetime
  end
end

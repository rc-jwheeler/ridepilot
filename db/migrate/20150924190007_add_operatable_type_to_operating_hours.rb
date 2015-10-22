class AddOperatableTypeToOperatingHours < ActiveRecord::Migration
  def change
    add_column :operating_hours, :operatable_type, :string
  end
end

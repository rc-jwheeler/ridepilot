class DropDefaultFromAInDistrictColumn < ActiveRecord::Migration
  def change
    change_column :addresses, :in_district, :boolean, default: nil
  end
end

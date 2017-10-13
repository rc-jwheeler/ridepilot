class AddVersionToCustomReport < ActiveRecord::Migration
  def change
    add_column :custom_reports, :version, :string
  end
end

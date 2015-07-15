class LookupTable < ActiveRecord::Base  
  validates_presence_of :name, :caption, :value_column_name
  validates_uniqueness_of :name

  def values
    model.all.order(value_column_name)
  end

  def model
    name.constantize
  end

  def find(value)
    model.find_by("#{value_column_name}": value)
  end

  def add_value(value)
    model.create("#{value_column_name}": value) if add_value_allowed
  end

  def update_value(old_value, new_value)
    item = find(old_value)
    item.update("#{value_column_name}": new_value) if item && edit_value_allowed
    item
  end

  def destroy_value(value)
    item = find(value)
    item.destroy if item && delete_value_allowed

    item
  end
end

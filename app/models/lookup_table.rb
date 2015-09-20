class LookupTable < ActiveRecord::Base  
  validates_presence_of :name, :caption, :value_column_name
  validates_uniqueness_of :name

  def values
    model.all.order(value_column_name)
  end

  def model
    (model_name || name.classify).constantize
  end

  def find_by_value(value)
    model.find_by("#{value_column_name}": value)
  end

  def add_value(value)
    model.create("#{value_column_name}": value) rescue nil if add_value_allowed
  end

  def update_value(model_id, new_value)
    item = model.find_by_id(model_id)
    item.update("#{value_column_name}": new_value) if item && edit_value_allowed
    item
  end

  def destroy_value(model_id)
    item = model.find_by_id(model_id)
    item.destroy if item && delete_value_allowed

    item
  end

  def get_value(model_id)
    model.find_by_id(model_id)
  end

  def hide_value(model_id, provider_id)
    HiddenLookupTableValue.hide_value(name, provider_id, model_id)
  end

  def show_value(model_id, provider_id)
    HiddenLookupTableValue.show_value(name, provider_id, model_id)
  end
end

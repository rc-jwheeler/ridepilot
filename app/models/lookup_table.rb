class LookupTable < ActiveRecord::Base  
  # Each lookup table can have three columns associated: value, code, description
  # e.g., TripResult has all three, but mostly only has one column, which is used as 'value' to identify each record
  # Eligibility is a special case, because its value column is named as code, so value_column_name should be 'code'
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

  def add_value(data)
    if add_value_allowed
      data_config = {
        "#{value_column_name}": data[:value]
      }
      
      data_config["#{code_column_name}"] = data[:code] if code_column_name.present?
      data_config["#{description_column_name}"] = data[:description] if description_column_name.present?

      item = model.new(data_config) 
      item.save

      item
    else
      nil
    end
  end

  def update_value(model_id, new_data)
    item = model.find_by_id(model_id)
    if item && edit_value_allowed
      data_config = {
        "#{value_column_name}": new_data[:value]
      }
      
      data_config["#{code_column_name}"] = new_data[:code] if code_column_name.present?
      data_config["#{description_column_name}"] = new_data[:description] if description_column_name.present?

      item.assign_attributes(data_config)

      item.save

      item
    end

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

class LookupTable < ActiveRecord::Base
  validates_presence_of :name, :caption, :value_column_name
  validates_uniqueness_of :name
end

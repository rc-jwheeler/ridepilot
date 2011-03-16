class Customer < ActiveRecord::Base
  belongs_to :provider
  belongs_to :address
  accepts_nested_attributes_for :address

  def name
    if group
      return "(Group) %s" % first_name
    end
    if middle_initial
      return "%s %s. %s" % [first_name, middle_initial, last_name]
    else
      return "%s %s " % [first_name, last_name]
    end
  end

end

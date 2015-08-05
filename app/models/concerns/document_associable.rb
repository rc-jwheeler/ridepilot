require 'active_support/concern'

# Use with `include DocumentAssociable`
# Assumes that the associable will be either a DriverHistory, DriverCompliance,
# or (soon) some sort of vehicle event model, and thus that the owner will be
# either a Driver or a Vehicle. 
module DocumentAssociable
  extend ActiveSupport::Concern

  included do
    has_many :document_associations, as: :associable, dependent: :destroy
    accepts_nested_attributes_for :document_associations, allow_destroy: true, reject_if: :all_blank
  end
  
  # This is mainly available for testing
  def associable_owner
    # This should be either a driver or a vehicle. If others are required, make
    # sure to account for them below, or make the including class define this 
    # method
     if self.respond_to? :driver
       driver
     elsif self.respond_to? :vehicle
       vehicle
     else
       raise "Unsupported associable object"
     end
  end
  
  # This is mainly available for testing
  def associable_owner=(owner)
    # This should be either a driver or a vehicle. If others are required, make
    # sure to account for them below, or make the including class define this 
    # method
     if self.respond_to? :driver
       self.driver = owner
     elsif self.respond_to? :vehicle
       self.vehicle = owner
     else
       raise "Unsupported associable object"
     end
  end
  
  def name
    # The associable will probably have a field named `event` that we can use.
    # If it gets more complex as other associable models are created, we could
    # make the including class define this method or add branching logic and 
    # raise an error if it's not detectable.
    if associable.respond_to? :event
      associable.event
    else
      associable.to_s
    end
  end
end



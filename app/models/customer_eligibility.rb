class CustomerEligibility < ActiveRecord::Base
  belongs_to :customer
  belongs_to :eligibility

  validates :customer, presence: true
  validates :eligibility, presence: true
end

class Eligibility < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true
  validates :description, presence: true

  has_many :customers, through: :customer_eligibilities
  has_many :customer_eligibilities
end


class Eligibility < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true
  validates :description, presence: true
end


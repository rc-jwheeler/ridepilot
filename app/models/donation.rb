class Donation < ActiveRecord::Base
  belongs_to :customer
  belongs_to :user
  belongs_to :trip

  validates :date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :customer, presence: true
  validates :user, presence: true
end

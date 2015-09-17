class Donation < ActiveRecord::Base
  belongs_to :customer
  belongs_to :user
  belongs_to :trip

  validates :date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :customer, presence: true
  validates :user, presence: true

  def self.parse(donation_hash, customer, user)
    utility = Utility.new
    Donation.new({
      date: utility.parse_datetime(donation_hash[:date]) ,
      amount: donation_hash[:amount].to_f,
      notes: donation_hash[:notes],
      customer: customer,
      user: user
      })
  end
end

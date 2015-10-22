class BookingUser < ActiveRecord::Base

  belongs_to :user
  validates :user, presence: true

  # Token is auto-generated at database level via uuid extension
  
  acts_as_paranoid # soft delete
end

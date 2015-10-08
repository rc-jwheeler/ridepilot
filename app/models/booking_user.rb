class BookingUser < ActiveRecord::Base

  belongs_to :user
  validates :user, presence: true, uniqueness: { conditions: -> { where(deleted_at: nil) } }

  # Token is auto-generated at database level via uuid extension
  
  acts_as_paranoid # soft delete
end

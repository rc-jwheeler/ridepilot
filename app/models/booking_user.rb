class BookingUser < ActiveRecord::Base

  belongs_to :user
  validates :user, presence: true, uniqueness: { conditions: -> { where(deleted_at: nil) } }
  validates :token, presence: true, uniqueness: { conditions: -> { where(deleted_at: nil) } }
  
  acts_as_paranoid # soft delete
end

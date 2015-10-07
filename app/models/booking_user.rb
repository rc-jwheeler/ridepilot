require 'securerandom'

class BookingUser < ActiveRecord::Base
  before_validation :generate_uuid_token, on: :create

  belongs_to :user
  validates :user, presence: true, uniqueness: { conditions: -> { where(deleted_at: nil) } }
  validates :token, presence: true, uniqueness: { conditions: -> { where(deleted_at: nil) } }
  
  acts_as_paranoid # soft delete

  private

  def generate_uuid_token
    self.token = SecureRandom.uuid
  end
end

class Driver < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :provider
  belongs_to :user
  
  has_one :device_pool_driver, dependent: :destroy
  has_one :device_pool, through: :device_pool_driver
  
  validates :user_id, uniqueness: {allow_nil: true}
  validates :name, uniqueness: {scope: :provider_id}, length: {minimum: 2}
  validates :email, format: {with: Devise.email_regexp, allow_blank: true}

  scope :users,         -> { where("drivers.user_id IS NOT NULL") }
  scope :active,        -> { where(active: true) }
  scope :for_provider,  -> (provider_id) { where(provider_id: provider_id) }
  scope :default_order, -> { order(:name) }
  
  def self.unassigned(provider)
    users.for_provider(provider).reject { |driver| driver.device_pool.present? }
  end
end

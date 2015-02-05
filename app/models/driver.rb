class Driver < ActiveRecord::Base
  belongs_to :provider
  belongs_to :user
  
  has_one :device_pool_driver, :dependent => :destroy
  has_one :device_pool, :through => :device_pool_driver
  
  validates :user_id, :uniqueness => {:allow_nil => true}
  
  validates_uniqueness_of :name, :scope => :provider_id
  validates_length_of :name, :minimum=>2

  has_paper_trail
  
  scope :users,         -> { where("drivers.user_id IS NOT NULL") }
  scope :active,        -> { where(:active => true) }
  scope :for_provider,  -> (provider_id) { where(:provider_id => provider_id) }
  scope :default_order, -> { order(:name) }
  
  def self.unassigned(provider)
    users.for_provider(provider).reject { |driver| driver.device_pool.present? }
  end
  
end

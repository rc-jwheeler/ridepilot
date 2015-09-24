class Driver < ActiveRecord::Base
  include RequiredFieldValidatorModule
  include Operatable

  acts_as_paranoid # soft delete

  has_paper_trail
  
  belongs_to :address
  belongs_to :provider
  belongs_to :user
  
  has_one :device_pool_driver, dependent: :destroy
  has_one :device_pool, through: :device_pool_driver

  has_many :documents, as: :documentable, dependent: :destroy, inverse_of: :documentable
  has_many :driver_histories, dependent: :destroy, inverse_of: :driver
  
  # We must specify :delete_all in order to avoid the before_destroy hook. See
  # the RecurringComplianceEvent concern for more details. 
  # TODO Look into using `#mark_for_destruction` and `#marked_for_destruction?`
  has_many :driver_compliances, dependent: :delete_all, inverse_of: :driver

  accepts_nested_attributes_for :address, update_only: true

  validates :address, associated: true
  validates :email, format: { with: Devise.email_regexp, allow_blank: true }
  validates :name, uniqueness: { scope: :provider_id }, length: { minimum: 2 }
  validates :provider, presence: true
  validates :user, presence: true
  validates :user_id, uniqueness: { allow_nil: true }

  scope :users,         -> { where("drivers.user_id IS NOT NULL") }
  scope :active,        -> { where(active: true) }
  scope :for_provider,  -> (provider_id) { where(provider_id: provider_id) }
  scope :default_order, -> { order(:name) }
  
  def self.unassigned(provider)
    users.for_provider(provider).reject { |driver| driver.device_pool.present? }
  end
  
  def compliant?(as_of: Date.current)
    driver_compliances.overdue(as_of: as_of).empty?
  end
end

class Vehicle < ActiveRecord::Base
  has_paper_trail

  belongs_to :provider
  belongs_to :default_driver, :class_name => "Driver"
  
  has_one :device_pool_driver, :dependent => :destroy
  has_one :device_pool, :through => :device_pool_driver
  
  has_many :vehicle_maintenance_events, dependent: :destroy, inverse_of: :vehicle

  validates :provider, presence: true
  validates :default_driver, presence: true
  validates :name, presence: true
  validates :vin, length: {is: 17, allow_nil: true, allow_blank: true},
    format: {with: /\A[^ioq]*\z/i, allow_nil: true}

  default_scope { order('active, name') }
  scope :active,       -> { where(:active => true) }
  scope :for_provider, -> (provider_id) { where(:provider_id => provider_id) }
  scope :reportable,   -> { where(:reportable => true) }

  def self.unassigned(provider)
    for_provider(provider).reject { |vehicle| vehicle.device_pool.present? }
  end
end

class Vehicle < ActiveRecord::Base
  belongs_to :provider
  belongs_to :default_driver, :class_name => "Driver"
  
  has_one :device_pool_driver, :dependent => :destroy
  has_one :device_pool, :through => :device_pool_driver
  
  has_many :vehicle_maintenance_events

  default_scope { order('active, name') }
  scope :active,       -> { where(:active => true) }
  scope :for_provider, -> (provider_id) { where(:provider_id => provider_id) }
  scope :reportable,   -> { where(:reportable => true) }

  def self.unassigned(provider)
    for_provider(provider).reject { |vehicle| vehicle.device_pool.present? }
  end

  validates_length_of :vin, :is=>17, :allow_nil => true, :allow_blank => true
  validates_format_of :vin, :with => /\A[^ioq]*\z/i, :allow_nil => true

  has_paper_trail
end

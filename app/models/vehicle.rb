class Vehicle < ActiveRecord::Base
  OWNERSHIPS = [:agency, :volunteer].freeze

  has_paper_trail

  belongs_to :provider
  belongs_to :default_driver, :class_name => "Driver"
  
  has_one :device_pool_driver, :dependent => :destroy
  has_one :device_pool, :through => :device_pool_driver
  
  has_many :vehicle_maintenance_events, dependent: :destroy, inverse_of: :vehicle
  has_many :vehicle_maintenance_compliances, dependent: :destroy, inverse_of: :vehicle
  has_many :vehicle_warranties, dependent: :destroy, inverse_of: :vehicle
  has_many :runs, inverse_of: :vehicle # TODO add :dependent rule

  validates :provider, presence: true
  validates :default_driver, presence: true
  validates :name, presence: true
  validates :vin, length: {is: 17, allow_nil: true, allow_blank: true},
    format: {with: /\A[^ioq]*\z/i, allow_nil: true}
  validates_date :registration_expiration_date, allow_blank: true
  validates :seating_capacity, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :ownership, inclusion: { in: OWNERSHIPS.map(&:to_s), allow_blank: true }

  default_scope { order('active, name') }
  scope :active,       -> { where(:active => true) }
  scope :for_provider, -> (provider_id) { where(:provider_id => provider_id) }
  scope :reportable,   -> { where(:reportable => true) }

  def self.unassigned(provider)
    for_provider(provider).reject { |vehicle| vehicle.device_pool.present? }
  end

  def last_odometer_reading
    runs.where().not(end_odometer: nil).last.try(:end_odometer).to_i
  end

  def compliant?(as_of: Date.current)
    vehicle_maintenance_compliances.overdue(as_of: as_of).empty?
  end  

  def expired?(as_of: Date.current)
    vehicle_warranties.expired(as_of: as_of).any?
  end  
end

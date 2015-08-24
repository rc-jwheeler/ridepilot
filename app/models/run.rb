class Run < ActiveRecord::Base
  include RequiredFieldValidatorModule
  
  has_paper_trail
  
  FIELDS_FOR_COMPLETION = [
    :name, 
    :date, 
    :start_odometer, 
    :end_odometer, 
    :scheduled_start_time, 
    :scheduled_end_time, 
    :unpaid_driver_break_time, 
    :vehicle_id, 
    :driver_id, 
    :paid, 
    :provider_id, 
    :actual_start_time, 
    :actual_end_time, 
  ].freeze
  
  belongs_to :provider
  belongs_to :driver
  belongs_to :vehicle, inverse_of: :runs

  has_many :trips, -> { order(:pickup_time) }, :dependent => :nullify

  accepts_nested_attributes_for :trips
  
  before_validation :fix_dates, :set_complete 
  validates                 :driver, presence: true
  validates                 :provider, presence: true
  validates                 :vehicle, presence: true
  validates_datetime        :scheduled_start_time, :allow_blank => true
  validates_datetime        :scheduled_end_time, :after => :scheduled_start_time, :allow_blank => true
  validates_datetime        :actual_start_time, :allow_blank => true
  validates_datetime        :actual_end_time, :after => :actual_start_time, :allow_blank => true
  validates_date            :date
  validates_numericality_of :start_odometer, :allow_nil => true
  validates_numericality_of :end_odometer, :allow_nil => true
  validates_numericality_of :end_odometer, :allow_nil => true, :greater_than => Proc.new {|run| run.start_odometer }, :if => Proc.new {|run| run.start_odometer.present? }
  validates_numericality_of :end_odometer, :allow_nil => true, :less_than => Proc.new {|run| run.start_odometer + 500 }, :if => Proc.new {|run| run.start_odometer.present? }
  validates_numericality_of :unpaid_driver_break_time, :allow_nil => true
  # TODO discuss when to enable this:
  # validate                  :driver_availability
  
  scope :for_provider,           -> (provider_id) { where( :provider_id => provider_id ) }
  scope :for_vehicle,            -> (vehicle_id) { where(:vehicle_id => vehicle_id )}
  scope :for_paid_driver,        -> { where(:paid => true) }
  scope :for_volunteer_driver,   -> { where(:paid => false) }
  scope :incomplete_on,          -> (date) { where(:complete => false, :date => date) }
  scope :for_date_range,         -> (start_date, end_date) { where("runs.date >= ? and runs.date < ?", start_date, end_date) }
  scope :with_odometer_readings, -> { where("start_odometer IS NOT NULL and end_odometer IS NOT NULL") }
  scope :has_scheduled_time,     -> { where.not(scheduled_start_time: nil).where.not(scheduled_end_time: nil) }

  CAB_RUN_ID = -1 # id for cab runs 
  UNSCHEDULED_RUN_ID = -2 # id for unscheduled run (empty container)
  
  def cab=(value)
    @cab = value
  end

  def vehicle_name
    vehicle.name if vehicle.present?
  end
  
  def label
    if @cab
      "Cab"
    else
      !name.blank? ? name: "#{vehicle_name}: #{driver.try :name} #{scheduled_start_time.try :strftime, "%I:%M%P"}".gsub( /m$/, "" )
    end
  end
  
  def as_json(options)
    { :id => id, :label => label }
  end

  def as_calendar_json
    {
      id: id,
      start: scheduled_start_time ? scheduled_start_time.iso8601 : nil,
      end: scheduled_end_time ? scheduled_end_time.iso8601 : nil,
      title: label,
      resource: date.to_date.to_s(:js)
    }
  end

  def self.fake_cab_run
    Run.new name: TranslationEngine.translate_text(:cab), id: Run::CAB_RUN_ID
  end

  def self.fake_unscheduled_run
    Run.new name: TranslationEngine.translate_text(:unscheduled), id: Run::UNSCHEDULED_RUN_ID
  end

  private

  # A trip is considered complete if:
  #  actual_end_time is valued (which requires that actual_start_time is also valued)
  #  actual_end_time is before "now"
  #  None of its trips are still considered pending
  #  Any fields that the run provider has listed as required are valued
  def set_complete
    self.complete = actual_end_time.present? && actual_end_time < Time.zone.now && trips.incomplete.empty? && check_provider_fields_required_for_run_completion
    true
  end

  def fix_dates 
    d = self.date
    unless d.nil?
      unless scheduled_start_time.nil?
        s = scheduled_start_time 
        self.scheduled_start_time = Time.zone.local(d.year, d.month, d.day, s.hour, s.min, 0) 
        scheduled_start_time_will_change!
      end
      unless scheduled_end_time.nil?
        s = scheduled_end_time
        self.scheduled_end_time = Time.zone.local(d.year, d.month, d.day, s.hour, s.min, 0) 
        scheduled_end_time_will_change!
      end
      unless actual_start_time.nil?
        a = actual_start_time
        self.actual_start_time = Time.zone.local(d.year, d.month, d.day, a.hour, a.min, 0) 
        actual_start_time_will_change!
      end
      unless actual_end_time.nil?
        a = actual_end_time
        self.actual_end_time = Time.zone.local(d.year, d.month, d.day, a.hour, a.min, 0)
        actual_end_time_will_change!
      end
    end
    true
  end

  def driver_availability
    if date && scheduled_start_time && driver && !driver.available?(date.wday, scheduled_start_time.strftime('%H:%M'))
      errors.add(:driver_id, TranslationEngine.translate_text(:unavailable_at_run_time))
    end
  end
  
  def check_provider_fields_required_for_run_completion
    provider.present? && provider.fields_required_for_run_completion.select{ |attr| self[attr].blank? }.empty?
  end
end

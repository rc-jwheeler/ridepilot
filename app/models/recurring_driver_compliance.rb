class RecurringDriverCompliance < ActiveRecord::Base
  RECURRENCE_SCHEDULES = [:days, :weeks, :months, :years].freeze
  FUTURE_START_RULES = [:immediately, :on_schedule, :time_span].freeze
  
  belongs_to :provider
  
  has_many :drivers, through: :provider
  has_many :driver_compliances # No :dependent option. See around_destroy
  
  scope :default_order, -> { order("start_date DESC") }
  
  validates :provider, presence: true
  validates :event_name, presence: true
  validates :recurrence_schedule, inclusion: { in: RECURRENCE_SCHEDULES.map(&:to_s) }
  validates :recurrence_frequency, numericality: { only_integer: true, greater_than: 0 }
  validates :future_start_rule, inclusion: { in: FUTURE_START_RULES.map(&:to_s) }
  validates :future_start_schedule, inclusion: { in: RECURRENCE_SCHEDULES.map(&:to_s), if: :future_start_rule_is_time_span? }
  validates :future_start_frequency, numericality: { only_integer: true, greater_than: 0, if: :future_start_rule_is_time_span? }
  validates :compliance_date_based_scheduling, inclusion: { in: [true, false] }
  validates_date :start_date, on_or_after: -> { Date.current }
  
  def future_start_rule_is_time_span?
    future_start_rule.to_sym == :time_span
  end
end

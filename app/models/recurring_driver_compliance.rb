require 'chronic'

class RecurringDriverCompliance < ActiveRecord::Base
  RECURRENCE_SCHEDULES = [:days, :weeks, :months, :years].freeze
  FUTURE_START_RULES = [:immediately, :on_schedule, :time_span].freeze
  
  after_update :update_children

  belongs_to :provider, inverse_of: :recurring_driver_compliances
  
  has_many :drivers, through: :provider
  has_many :driver_compliances, :dependent => :nullify, inverse_of: :recurring_driver_compliance
  
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
  validate :limit_updates_on_recurrences_with_children, on: :update
  
  def destroy_with_incomplete_children!
    RecurringDriverCompliance.transaction do
      child_ids = driver_compliances.incomplete.pluck(:id)
      self.destroy
      DriverCompliance.destroy_all(id: child_ids)
    end
  end
  
  class << self
    def generate!
      transaction do
        find_each do |recurrence|
          recurrence.drivers.find_each do |driver|
            missing_occurrences = calculate_occurrence_dates(recurrence: recurrence) - recurrence.driver_compliances.for(driver).pluck(:due_date)
            missing_occurrences.each do |occurrence_date|
              driver.driver_compliances.create! event: recurrence.event_name,
                notes: recurrence.event_notes,
                due_date: occurrence_date,
                recurring_driver_compliance: recurrence
            end
          end
        end
      end
    end
  
    def calculate_occurrence_dates(recurrence:, first_date: nil, end_date: nil)
      next_date = (first_date ||= recurrence.start_date)
      end_date ||= (Date.current + 6.months)
      occurrences = []
      loop do
        break if next_date > end_date
        occurrences << next_date
        next_date = first_date + (recurrence.recurrence_frequency * occurrences.size).send(recurrence.recurrence_schedule)
      end
      occurrences
    end
  end  
  
  private
  
  def future_start_rule_is_time_span?
    future_start_rule.present? && future_start_rule.to_sym == :time_span
  end

  # Only allow updating the event_name and event_notes fields if the record is
  # associated with any DriverCompliance records
  def limit_updates_on_recurrences_with_children
    if driver_compliances.any?
      changed_attributes.except(:event_name, :event_notes).keys.each do |key|
        errors.add(key, "cannot be modified once events have been generated")
      end
    end
  end
  
  def update_children
    driver_compliances.update_all event: event_name, notes: event_notes
  end
end

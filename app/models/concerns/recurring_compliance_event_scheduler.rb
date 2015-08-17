require 'active_support/concern'

module RecurringComplianceEventScheduler
  extend ActiveSupport::Concern

  included do
    RECURRENCE_SCHEDULES = [:days, :weeks, :months, :years].freeze
    FUTURE_START_RULES = [:immediately, :on_schedule, :time_span].freeze
  
    belongs_to :provider
  
    after_update :update_children

    scope :default_order, -> { order("start_date DESC") }
  
    validates :provider, presence: true
    validates :event_name, presence: true
    validates :recurrence_schedule, inclusion: { in: RECURRENCE_SCHEDULES.map(&:to_s), allow_blank: true }
    validates :recurrence_frequency, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
    validates :future_start_rule, inclusion: { in: FUTURE_START_RULES.map(&:to_s) }
    validates :future_start_schedule, inclusion: { in: RECURRENCE_SCHEDULES.map(&:to_s), if: :future_start_rule_is_time_span? }
    validates :future_start_frequency, numericality: { only_integer: true, greater_than: 0, if: :future_start_rule_is_time_span? }
    validates_date :start_date, on_or_after: -> { Date.current }
    validate :limit_updates_on_recurrences_with_children, on: :update
      
    def destroy_with_incomplete_children!
      self.class.transaction do
        child_ids = self.send(self.class.recurring_compliance_association).incomplete.pluck(:id)
        self.destroy
        self.class.recurring_compliance_class.destroy_all(id: child_ids)
      end
    end

    private
    
    def future_start_rule_is_time_span?
      future_start_rule.present? && future_start_rule.to_sym == :time_span
    end

    # Only allow updating the event_name and event_notes fields if the record is
    # associated with any DriverCompliance records
    def limit_updates_on_recurrences_with_children
      if self.send(self.class.recurring_compliance_association).any?
        changed_attributes.except(:recurrence_notes, :event_name, :event_notes).keys.each do |key|
          errors.add(key, "cannot be modified once events have been generated")
        end
      end
    end

    def update_children
      self.send(self.class.recurring_compliance_association).update_all event: event_name, notes: event_notes
    end
  end
  
  module ClassMethods 
    attr_reader :recurring_compliance_association
    attr_reader :recurring_compliance_class

    def generate!
      raise "Must be defined by including class"
    end
    
    private

    def creates_occurrences_on(association, class_name: nil)
      @recurring_compliance_association = association
      @recurring_compliance_class = if class_name.present?
        if class_name.is_a? String
          class_name.constantize
        else
          class_name
        end
      else
        association.to_s.singularize.camelize.constantize
      end
    end
  end
end

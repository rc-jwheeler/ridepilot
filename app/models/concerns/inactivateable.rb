require 'active_support/concern'

# Use with `include Inactivateable`
# Owner will be able to configure its availability
module Inactivateable
  extend ActiveSupport::Concern

  included do
    def inactivated?
      # permanent inactive
      # or, inactive for a date range
      permanent_inactivated? || temporarily_inactivated?
    end

    def permanent_inactivated?
      !active
    end

    def temporarily_inactivated?
      !permanent_inactivated? && (inactivated_start_date.present? || inactivated_end_date.present?)
    end

    def active_status_text
      if !inactivated?
        "active"
      elsif permanent_inactivated?
        "permanently out of service"
      elsif temporarily_inactivated?
        if inactivated_end_date.present?
          "temporarily inactive from #{inactivated_start_date.try(:strftime, '%m/%d/%Y')} to #{inactivated_end_date.try(:strftime, '%m/%d/%Y')}"
        else
          "temporarily inactive from #{inactivated_start_date.try(:strftime, '%m/%d/%Y')}"
        end
      end
    end
  end
end



require 'active_support/concern'

module OperatingHourCore
  extend ActiveSupport::Concern

  START_OF_DAY = '01:00:00'
  END_OF_DAY = '00:59:59' # The next morning

  included do
    belongs_to :operatable, polymorphic: true

    validates_presence_of :operatable
    validate :enforce_hour_sanity

    # Notes:
    # - start_time and end_time should be saved as strings, and w/o TZ info
    # - start_time == 00:00 and end_time == 00:00 represents 24-hours
    # - If unavailable, then both times should be nil.

    def make_unavailable
      self.start_time = nil
      self.end_time = nil
    end
    
    def is_unavailable?
      self.start_time.nil? and self.end_time.nil?
    end
    
    def make_24_hours
      self.start_time = '00:00'
      self.end_time = '00:00'
    end
    
    def is_24_hours?
      start_time.try(:to_s, :time_utc) == '00:00:00' and end_time.try(:to_s, :time_utc) == '00:00:00'
    end
    
    def is_regular_hours?
      !is_unavailable? and !is_24_hours?
    end
    
  end

  
  module ClassMethods  
    # Create an array of start times in UTC format
    def available_start_times(interval: 30.minutes)
      start_time = Time.zone.parse(START_OF_DAY)
      end_time = start_time.at_end_of_day
      get_times_between start_time: start_time, end_time: end_time, interval: interval
    end
    
    # Create an array of end times in UTC format
    def available_end_times(interval: 30.minutes)
      start_time = Time.zone.parse(START_OF_DAY)
      end_time = Time.zone.parse(END_OF_DAY) + 1.day # END_OF_DAY > midnight
      get_times_between start_time: start_time, end_time: end_time, interval: interval
    end

    def operating_for_time?(time_of_day = Time.current.strftime('%H:%M'))
      is_operating = false

      first_recur_config = self.first
      if first_recur_config.is_unavailable?
        is_operating = false
      elsif first_recur_config.is_24_hours?
        is_operating = true
      else
        self.pluck(:start_time, :end_time).each do |op|
          op_start_time = op[0]
          op_end_time = op[1]
          is_covered = if op_start_time > op_end_time
            time_of_day >= op_start_time.strftime('%H:%M') || time_of_day <= op_end_time.strftime('%H:%M')
          elsif op_start_time != op_end_time
            time_of_day.between? op_start_time.strftime('%H:%M'), op_end_time.strftime('%H:%M')
          else
            false
          end

          if is_covered
            is_operating = true
            break
          end
        end
      end

      is_operating
    end

    def operating_between_time?(start_time = Time.current.strftime('%H:%M'), end_time = Time.current.strftime('%H:%M'))
      is_operating = false

      first_recur_config = self.first
      if first_recur_config.is_unavailable?
        is_operating = false
      elsif first_recur_config.is_24_hours?
        is_operating = true
      else
        self.pluck(:start_time, :end_time).each do |op|
          op_start_time = op[0]
          op_end_time = op[1]

          is_covered = if op_start_time != op_end_time 
            (start_time && start_time.between?(op_start_time.strftime('%H:%M'), op_end_time.strftime('%H:%M'))) && 
            (end_time && end_time.between?(op_start_time.strftime('%H:%M'), op_end_time.strftime('%H:%M')))
          else
            false
          end

          if is_covered
            is_operating = true
            break
          end
        end
      end

      is_operating
    end
    
    private
    
    def get_times_between(start_time:, end_time:, interval: 30.minutes)
      # We only need the time as a string, but we'll use some temporary Time
      # objects to help us do some simple time math. The dates returned are
      # irrelevant
      times =[]
      t = start_time
      while t < end_time
        times << t.to_s(:time_utc)
        t += interval
      end
      times
    end
  end

  private

  def enforce_hour_sanity
    # end_time > END_OF_DAY to allow hours such as 12:00pm - 3:00am (next day)
    if is_regular_hours? and start_time >= end_time and end_time.try(:to_s, :time_utc) > END_OF_DAY
      errors.add(:end_time, 'must be later than start time.')
    end
  end

end

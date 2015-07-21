class OperatingHours < ActiveRecord::Base
  belongs_to :driver

  validates_presence_of :day_of_week, :driver
  validate :enforce_hour_sanity

  default_scope -> { order :day_of_week }

  START_OF_DAY = '05:00:00'
  END_OF_DAY = '03:00:00'

  # Notes:
  # - start_time and end_time should be saved as strings, and w/o TZ info
  # - start_time == 0:00 and end_time == 0:00 represents 24-hours
  # - If closed, then hours should be null.

  # def make_closed!
  #   self.start_time = nil
  #   self.end_time = nil
  # end
  
  def is_closed?
    self.start_time.nil? and self.end_time.nil?
  end
  
  # def make_24_hours!
  #   self.start_time = '00:00'
  #   self.end_time = '00:00'
  # end
  
  def is_24_hours?
    start_time.try(:to_s,:time_utc) == '00:00:00' and end_time.try(:to_s, :time_utc) == '00:00:00'
  end
  
  def is_regular_hours?
    !is_closed? and !is_24_hours?
  end
  
  private

  def enforce_hour_sanity
    # end_time > END_OF_DAY to allow hours such as 12:00pm - 3:00am (next day)
    if is_regular_hours? and start_time >= end_time and end_time.try(:to_s, :time_utc) > END_OF_DAY
      errors.add(:end_time, 'must be later than open time.')
    end
  end
end

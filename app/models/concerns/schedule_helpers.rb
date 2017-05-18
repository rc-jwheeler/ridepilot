module ScheduleHelpers
  
  # Returns an array of the schedule's weekly rules
  def schedule_weekly_rules
    schedule.to_hash[:rrules].select {|rule| rule[:rule_type] == "IceCube::WeeklyRule" }
  end
  
  # Returns the start date of the schedule
  def schedule_start_date
    schedule.to_hash[:start_date]
  end

  # Returns the interval of the (first) weekly schedule rule
  def schedule_interval
    schedule_weekly_rules[0][:interval]
  end
  
  # Returns the days of the week that a schedule 
  def schedule_weekdays
    schedule_weekly_rules
      .map {|rule| rule[:validations][:day] }
      .flatten.compact
  end
  
  # Gets the number of weeks between two dates
  def weeks_offset(date1, date2)
    ((date1.beginning_of_week - date2.beginning_of_week).to_i / 7).abs
  end
  
  # Checks for intersection of two arithmetic sequences
  def recurrences_intersect?(offset, interval1, interval2)
    (offset % (interval1.gcd(interval2))).zero?
  end
  
  # Checks if this record's schedule conflicts with another record's schedule
  # Currently, only checks for weekly recurrence conflicts
  def schedule_conflicts_with?(other_record)
    # Check if there is any day of week overlap, return false if not.
    return false if (schedule_weekdays & other_record.schedule_weekdays).empty?

    # Check for collision based on start date and repeat interval
    offset = weeks_offset(schedule_start_date, other_record.schedule_start_date)
    return recurrences_intersect?(offset, schedule_interval, other_record.schedule_interval)
  end
  
end

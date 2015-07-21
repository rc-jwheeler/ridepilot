class TripFilter 

  attr_reader :trips, :filters

  def initialize(trips, filters = {})
    @trips = trips
    @filters = filters
  end

  def filter!
    filter_by_pickup_time!
    filter_by_vehicle!
    filter_by_status!

    @filters.each do |k, v|
      next if [:start, :end, :vehicle_id, :status_id].index(k) # has been processed above

      @trips = @trips.where("#{k}": v) if !v.blank?
    end

    @trips
  end

  private 

  def filter_by_pickup_time!
    if @filters[:end].present? && @filters[:start].present?
      t_start = Time.at(@filters[:start].to_i).to_date.in_time_zone.utc
      t_end   = Time.at(@filters[:end].to_i).to_date.in_time_zone.utc
    else
      time    = Time.now
      t_start = time.beginning_of_week.to_date.in_time_zone.utc
      t_end   = t_start + 6.days
    end

    @trips = @trips.
      where("pickup_time >= '#{t_start.strftime "%Y-%m-%d %H:%M:%S"}'").
      where("pickup_time <= '#{t_end.strftime "%Y-%m-%d %H:%M:%S"}'").order(:pickup_time)
  end

  def filter_by_vehicle!
    if @filters[:vehicle_id].present?  
      if @filters[:vehicle_id].to_i == -1
        @trips = @trips.where(cab: true)
      else
        @trips = @trips.where(vehicle_id: @filters[:vehicle_id]) 
      end
    end
  end

  def filter_by_status!
    if @filters[:status_id].present?  
      if @filters[:status_id].to_i == 1
        @trips = @trips.where("run_id is NOT NULL or cab = true")
      else
        @trips = @trips.where("run_id is NULL and cab = false")
      end
    end
  end

end
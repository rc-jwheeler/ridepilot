require 'active_support/concern'

# Use with `include ItineraryCore`
module ItineraryCore
  extend ActiveSupport::Concern

  included do
    #belongs_to :trip
    #belongs_to :run
    belongs_to :address

    scope :revenue, -> { where.not(trip: nil) }
    scope :deadhead, -> { where(trip: nil) }

    def trip_id
      @trip_id ||= trip.id
    end

    def prev
      #TODO
      @prev 
    end

    def next
      #TODO
      @next
    end

    def ordinal 
      @ordinal ||= case leg_flag 
      when 0
        0
      when 1..2
        zero_index = (run.manifest_order || []).try(:index, itin_id)
        zero_index ? (zero_index + 1) : -1
      when 3
        run.manifest_order.size + 1
      end
    end

    def scheduled_time
      @scheduled_time ||= time || (leg_flag == 2 ? trip.pickup_time : nil) 
    end

    # scheduled time delta since midnight of day
    def time_diff
      @time_diff ||= time_portion(scheduled_time) 
    end

    def to_address
      @to_address ||= @next.address if @next
    end

    def capacity=(capacity)
      @capacity = capacity
    end

    def capacity
      @capacity
    end

    def capacity_warning=(capacity_warning)
      @capacity_warning = capacity_warning
    end

    def capacity_warning
      @capacity_warning
    end

    def itin_id 
      case leg_flag 
      when 0 
        "run_begin"
      when 1..2 # Pickup or dropoff
        "trip_#{trip_id}_leg_#{leg_flag}"
      when 3 
        "run_end"
      end
    end

    def eta 
      # previous leg depart_time + travel_time
      @eta ||= @prev.depart_time + @prev.travel_time.minutes if @prev && @prev.depart_time && @prev.travel_time
    end

    # in minutes
    def wait_time
      if trip && !trip.early_pickup_allowed && time
        eta_time = eta 
        ((time.to_i - eta.to_i) / 60.to_f).to_i if time > eta_time
      end
    end

    # in minutes
    def process_time
      if trip
        leg_flag == 1 ? trip.passenger_load_min : trip.passenger_unload_min
      end
    end

    def depart_time
      eta + process_time.minutes if eta && process_time
    end

    def travel_time
      if address && to_address && address.geocoded? && to_address.geocoded?
        params = {
          from_lat: address.latitude, 
          from_lon: address.longitude, 
          to_lat: to_address.latitude, 
          to_lon: to_address.longitude, 
          trip_datetime: eta || time
        }

        @travel_time ||= TripDistanceDurationProxy.new(ENV['TRIP_PLANNER_TYPE'], params).get_drive_time.to_f
      end
    end

    def clear_cache!
      @prev = @next = @ordinal = @to_address = @eta = @travel_time = nil
    end

    def time_portion(time)
      (time.to_i - time.beginning_of_day.to_i) if time
    end
  end
end



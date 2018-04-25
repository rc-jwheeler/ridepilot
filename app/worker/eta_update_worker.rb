class EtaUpdateWorker
  include Sidekiq::Worker

  def perform(itin_id, new_eta_str)
    return unless itin_id && new_eta_str

    Rails.logger.info "EtaUpdateWorker#perform, itin_id=#{itin_id}, new_eta=#{new_eta_str}"
    
    itin = Itinerary.find_by_id(itin_id)
    new_eta = Time.parse(new_eta_str)
    if itin && new_eta
      run = itin.run 
      old_eta = itin.eta
      eta_diff_seconds = (new_eta - old_eta).to_i if new_eta && old_eta
      itin.eta = new_eta 
      itin.save(validate: false)

      if eta_diff_seconds && eta_diff_seconds != 0
        itins = run.sorted_itineraries
        itin_index = itins.index(itin)
        if itin_index
          last_eta = itin.eta
          itins[itin_index+1..-1].each do |itin|
            if last_eta && itin.is_pickup? && !itin.trip.early_pickup_allowed 
              # if early pickup not allowed, then need to check if ETA > scheduled_time
              if last_eta <= itin.time
                break
              else
                # otherwise, re-calculate eta diff based on this leg
                eta_diff_seconds = (last_eta - itin.time).to_i
              end
            end

            if itin.eta 
              itin.eta = itin.eta + (eta_diff_seconds).seconds 
              itin.save(validate: false)
              last_eta = itin.eta
            end
          end
        end
      end
    end 
  end
end

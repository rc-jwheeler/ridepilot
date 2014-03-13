module TripsHelper
  def add_new_trip_via_run_page?
    params[:run_id].present? && current_user.current_provider.allow_trip_entry_from_runs_page
  end
end

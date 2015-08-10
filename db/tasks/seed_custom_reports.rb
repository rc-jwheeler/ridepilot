[
  'vehicles_monthly',
  'service_summary',
  'donations',
  'cab',
  'age_and_ethnicity',
  'monthlies'].each do |report_name|
  report = CustomReport.where(name: report_name).first_or_create 
  report.update(redirect_to_results: true)
end

[
  'show_trips_for_verification',
  'show_runs_for_verification',
  'daily_manifest',
  'daily_manifest_with_cab',
  'daily_manifest_by_half_hour',
  'daily_manifest_by_half_hour_with_cab',
  'daily_trips',
  'export_trips_in_range',
  'customer_receiving_trips_in_range',
  'cctc_summary_report'].each do | report_name |
  CustomReport.where(name: report_name).first_or_create
end
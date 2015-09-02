class ActiveRecord::Base
  private
  def format_datetime(datetime)
    if datetime.is_a?(String)
      begin
        Time.zone.parse(datetime.gsub(/\b(a|p)\b/i, '\1m').upcase)
      rescue 
        nil
      end
    else
      datetime
    end
  end
end
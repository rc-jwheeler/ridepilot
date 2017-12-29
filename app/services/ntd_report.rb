# NTD Report
# Modify an existing blank template

class NtdReport

  TEMPLATE_PATH = "#{Rails.root}/public/ntd_template.xlsx"
  
  attr_reader :workbook

  def initialize(year, month)
    @year = year
    @month = month
  end

  def export!
    @workbook = RubyXL::Parser.parse(TEMPLATE_PATH)
    @worksheet = @workbook[0] #first worksheet

    process_periods_of_service
    process_year_month_headers
    process_operations
    process_miles
    process_hours

    @workbook
  end

  private

  def process_periods_of_service
  end

  def process_year_month_headers
    # update row 4 with reporting year and month names
    @worksheet[4][3].change_value @year

    (1..12).each do |m|
      @worksheet[4][m + 4].change_value Date.new(@year, m, 1)
    end
    
  end

  def process_operations
  end

  def process_miles
  end

  def process_hours
  end

end
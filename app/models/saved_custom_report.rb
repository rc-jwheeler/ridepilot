class SavedCustomReport < ActiveRecord::Base
  belongs_to :custom_report
  belongs_to :provider

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :provider }

  scope :active_per_provider, -> (provider_id) { where(provider_id: provider_id) }

  # Date Range Type Constants
  FIXED_DATES = 0
  PROMPT_DATES = 1
  LAST_7_DAYS = 2
  THIS_WEEK = 3
  LAST_30_DAYS = 4
  THIS_MONTH = 5
  THIS_QUARTER = 6
  YEAR_TO_DATE = 7


  def self.date_range_type_list
    [
      ["Fixed Dates", FIXED_DATES],
      ["Prompt New Dates", PROMPT_DATES],
      ["Last 7 Days", LAST_7_DAYS],
      ["Current Week", THIS_WEEK],
      ["Last 30 Days", LAST_30_DAYS],
      ["Current Month", THIS_MONTH],
      ["Current Quarter", THIS_QUARTER],
      ["Year to Date", YEAR_TO_DATE]
    ]
  end
end

class TripResult < ActiveRecord::Base
  acts_as_paranoid # soft delete
  has_paper_trail

  SHOW_ALL_ID = -2
  UNSCHEDULED_ID = -1

  CANCEL_CODES = ['CANC', 'LTCANC', 'SDCANC'] # Cancelled, Late Cancel, Same Day Cancel
  NON_DISPATCHABLE_CODES = CANCEL_CODES + ['UNMET', 'TD']
  
  validates_presence_of :name, :code

  def self.by_provider(provider)
    hidden_ids = HiddenLookupTableValue.hidden_ids self.table_name, provider.try(:id)
    where.not(id: hidden_ids)
  end

  def full_description
    description || name
  end

  def self.is_cancel_code?(code)
    CANCEL_CODES.include? code
  end

  def self.non_dispatchable_result_ids
    @non_dispatchable_result_ids ||= where(code: NON_DISPATCHABLE_CODES).pluck(:id)
  end
end

class TripResult < ActiveRecord::Base
  acts_as_paranoid # soft delete
  has_paper_trail

  SHOW_ALL_ID = -2
  UNSCHEDULED_ID = -1
  
  validates_presence_of :name, :code

  def self.by_provider(provider)
    hidden_ids = HiddenLookupTableValue.hidden_ids self.table_name, provider.try(:id)
    where.not(id: hidden_ids)
  end

  def full_description
    description || name
  end
end

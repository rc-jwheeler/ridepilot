class TripPurpose < ActiveRecord::Base
  acts_as_paranoid # soft delete
  has_paper_trail
  
  validates_presence_of :name

  def self.by_provider(provider)
    hidden_ids = HiddenLookupTableValue.hidden_ids self.table_name, provider.try(:id)
    where.not(id: hidden_ids)
  end

  def as_api_json
    {
      name: name,
      code: id
    }
  end
end

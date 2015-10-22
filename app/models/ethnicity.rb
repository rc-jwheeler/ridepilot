class Ethnicity < ActiveRecord::Base
  acts_as_paranoid # soft delete

  validates :name, :length => { :minimum => 2 }

  default_scope { order('name') }

  has_paper_trail

  def self.by_provider(provider)
    hidden_ids = HiddenLookupTableValue.hidden_ids self.table_name, provider.try(:id)
    where.not(id: hidden_ids)
  end
end

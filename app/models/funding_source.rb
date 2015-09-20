class FundingSource < ActiveRecord::Base
  acts_as_paranoid # soft delete
  
  has_many :funding_source_visibilities, :dependent => :destroy
  has_many :providers, :through=>:funding_source_visibilities
  validates_presence_of :name
  validates_length_of :name, :minimum=>2

  def self.by_provider(provider)
    hidden_ids = HiddenLookupTableValue.hidden_ids self.table_name, provider.try(:id)
    where.not(id: hidden_ids)
  end
end

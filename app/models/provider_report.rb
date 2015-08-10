class ProviderReport < ActiveRecord::Base
  belongs_to :provider
  belongs_to :report

  validates :report_id, uniqueness: { scope: :provider_id, message: 'One report configuration per provider'}
end

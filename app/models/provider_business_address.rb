class ProviderBusinessAddress < Address
  validates :provider, presence: true 
end
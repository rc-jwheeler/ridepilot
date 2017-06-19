class ProviderMailingAddress < Address
  validates :provider, presence: true 
end
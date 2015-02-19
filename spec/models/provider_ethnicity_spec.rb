require "rails_helper"

RSpec.describe ProviderEthnicity do
  describe "provider_id" do
    it "should be an integer field" do
      c = ProviderEthnicity.new
      expect(c).to respond_to(:provider_id)
      c.provider_id = "1"
      expect(c.provider_id).to eq 1
      c.provider_id = "0"
      expect(c.provider_id).to eq 0
    end
  end
  
  describe "name" do
    it "should be a string field" do
      c = ProviderEthnicity.new
      expect(c).to respond_to(:name)
      c.name = "1"
      expect(c.name).to eq "1"
      c.name = "0"
      expect(c.name).to eq "0"
    end
  end
end

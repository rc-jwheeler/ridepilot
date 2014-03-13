require 'spec_helper'

describe ProviderEthnicity do
  describe "provider_id" do
    it "should be an integer field" do
      c = ProviderEthnicity.new
      c.should respond_to(:provider_id)
      c.provider_id = "1"
      c.provider_id.should eq 1
      c.provider_id = "0"
      c.provider_id.should eq 0
    end
  end
  
  describe "name" do
    it "should be a string field" do
      c = ProviderEthnicity.new
      c.should respond_to(:name)
      c.name = "1"
      c.name.should eq "1"
      c.name = "0"
      c.name.should eq "0"
    end
  end
end

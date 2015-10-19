require "rails_helper"

RSpec.describe Ethnicity do  
  describe "name" do
    it "should be a string field" do
      c = Ethnicity.new
      expect(c).to respond_to(:name)
      c.name = "1"
      expect(c.name).to eq "1"
      c.name = "0"
      expect(c.name).to eq "0"
    end
  end
end

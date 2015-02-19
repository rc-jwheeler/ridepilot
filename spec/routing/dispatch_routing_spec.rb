require "rails_helper"

RSpec.describe DispatchController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/dispatch").to route_to("dispatch#index")
    end

  end
end

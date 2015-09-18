require "rails_helper"

RSpec.describe HomeController, type: :routing do
  describe "routing" do

    it "routes admin tab to home#index" do
      expect(:get => "/admin").to route_to("home#index")
    end

  end
end

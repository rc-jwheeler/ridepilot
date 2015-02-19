require "rails_helper"

RSpec.describe MonthliesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/monthlies").to route_to("monthlies#index")
    end

    it "routes to #new" do
      expect(:get => "/monthlies/new").to route_to("monthlies#new")
    end

    it "routes to #show" do
      expect(:get => "/monthlies/1").to route_to("monthlies#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/monthlies/1/edit").to route_to("monthlies#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/monthlies").to route_to("monthlies#create")
    end

    it "routes to #update" do
      expect(:put => "/monthlies/1").to route_to("monthlies#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/monthlies/1").to route_to("monthlies#destroy", :id => "1")
    end

  end
end

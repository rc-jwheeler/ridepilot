require "rails_helper"

RSpec.describe FundingSourcesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/funding_sources").to route_to("funding_sources#index")
    end

    it "routes to #new" do
      expect(:get => "/funding_sources/new").to route_to("funding_sources#new")
    end

    it "routes to #show" do
      expect(:get => "/funding_sources/1").to route_to("funding_sources#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/funding_sources/1/edit").to route_to("funding_sources#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/funding_sources").to route_to("funding_sources#create")
    end

    it "routes to #update" do
      expect(:put => "/funding_sources/1").to route_to("funding_sources#update", :id => "1")
    end

    it "does not route to #destroy" do
      expect(:delete => "/funding_sources/1").to_not route_to("funding_sources#destroy", :id => "1")
    end

  end
end

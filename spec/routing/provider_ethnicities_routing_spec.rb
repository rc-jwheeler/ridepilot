require "rails_helper"

RSpec.describe ProviderEthnicitiesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/provider_ethnicities").to route_to("provider_ethnicities#index")
    end

    it "routes to #new" do
      expect(:get => "/provider_ethnicities/new").to route_to("provider_ethnicities#new")
    end

    it "routes to #show" do
      expect(:get => "/provider_ethnicities/1").to route_to("provider_ethnicities#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/provider_ethnicities/1/edit").to route_to("provider_ethnicities#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/provider_ethnicities").to route_to("provider_ethnicities#create")
    end

    it "routes to #update" do
      expect(:put => "/provider_ethnicities/1").to route_to("provider_ethnicities#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/provider_ethnicities/1").to route_to("provider_ethnicities#destroy", :id => "1")
    end

  end
end

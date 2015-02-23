require "rails_helper"

RSpec.describe AddressesController, type: :routing do
  describe "routing" do

    it "does not route to #index" do
      expect(:get => "/addresses").to_not route_to("addresses#index")
    end

    it "does not route to #new" do
      expect(:get => "/addresses/new").to_not route_to("addresses#new")
    end

    it "does not route to #show" do
      expect(:get => "/addresses/1").to_not route_to("addresses#show", :id => "1")
    end

    it "does not route to #edit" do
      expect(:get => "/addresses/1/edit").to_not route_to("addresses#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/addresses").to route_to("addresses#create")
    end

    it "routes to #update" do
      expect(:put => "/addresses/1").to route_to("addresses#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/addresses/1").to route_to("addresses#destroy", :id => "1")
    end

    it "routes to #autocomplete" do
      expect(:get => "/addresses/autocomplete").to route_to("addresses#autocomplete")
    end

    it "routes to #search" do
      expect(:get => "/addresses/search").to route_to("addresses#search")
    end

  end
end

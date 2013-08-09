require "spec_helper"

describe ResourcesController do
  describe "routing" do

    it "routes to #index" do
      get("/v1/resources").should route_to("resources#index")
    end

    it "routes to #show" do
      get("/v1/resources/1").should route_to("resources#show", :id => "1")
    end

    it "not route to #create" do
      post("/v1/resources").should_not be_routable
    end

    it "routes to #update" do
      put("/v1/resources/1").should route_to("resources#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/v1/resources/1").should route_to("resources#destroy", :id => "1")
    end

    it "routes to #rights to retrieve the collection" do
      get("/v1/resources/1/rights").should route_to("resources#rights", id: "1")
    end

    it "routes to #rights to create a new right" do
      post("/v1/resources/1/rights").should route_to("resources#right_create", id: "1")
    end

  end
end

require "spec_helper"

describe RightsController do
  describe "routing" do

    it "routes to #index" do
      get("/v1/rights").should route_to("rights#index")
    end

    it "routes to #show" do
      get("/v1/rights/1").should route_to("rights#show", :id => "1")
    end

    it "not route to #create" do
      post("/v1/rights").should_not be_routable
    end

    it "routes to #update" do
      put("/v1/rights/1").should route_to("rights#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/v1/rights/1").should route_to("rights#destroy", :id => "1")
    end

    it "routes to #groups" do
      get("/v1/rights/1/groups").should route_to("rights#groups", :id => "1")
    end

    it "routes to #roles" do
      get("/v1/rights/1/roles").should route_to("rights#roles", :id => "1")
    end

    it "routes to #connect to connect to another resource" do
      put("/v1/rights/1/connect").should route_to("rights#connect", id: "1")
    end

    it "routes to #disconnect to disconnect from a connected resource" do
      delete("/v1/rights/1/connect").should route_to("rights#disconnect", id: "1")
    end

  end
end

require "spec_helper"

describe RightsController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/v1/rights")).to route_to("rights#index")
    end

    it "routes to #show" do
      expect(get("/v1/rights/1")).to route_to("rights#show", :id => "1")
    end

    it "not route to #create" do
      expect(post("/v1/rights")).not_to be_routable
    end

    it "routes to #update" do
      expect(put("/v1/rights/1")).to route_to("rights#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/v1/rights/1")).to route_to("rights#destroy", :id => "1")
    end

    it "routes to #groups" do
      expect(get("/v1/rights/1/groups")).to route_to("rights#groups", :id => "1")
    end

    it "routes to #roles" do
      expect(get("/v1/rights/1/roles")).to route_to("rights#roles", :id => "1")
    end

    it "routes to #connect to connect to another resource" do
      expect(put("/v1/rights/1/connect")).to route_to("rights#connect", id: "1")
    end

    it "routes to #disconnect to disconnect from a connected resource" do
      expect(delete("/v1/rights/1/connect")).to route_to("rights#disconnect", id: "1")
    end

  end
end

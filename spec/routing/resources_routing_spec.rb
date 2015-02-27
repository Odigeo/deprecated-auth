require "spec_helper"

describe ResourcesController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/v1/resources")).to route_to("resources#index")
    end

    it "routes to #show" do
      expect(get("/v1/resources/1")).to route_to("resources#show", :id => "1")
    end

    it "should not route to #create" do
      expect(post("/v1/resources")).not_to be_routable
    end

    it "should not route to #update" do
      expect(put("/v1/resources/1")).not_to be_routable
    end

    it "should not route to #destroy" do
      expect(delete("/v1/resources/1")).not_to be_routable
    end

    it "routes to #rights to retrieve the collection" do
      expect(get("/v1/resources/1/rights")).to route_to("resources#rights", id: "1")
    end

    it "routes to #rights to create a new right" do
      expect(post("/v1/resources/1/rights")).to route_to("resources#right_create", id: "1")
    end

  end
end

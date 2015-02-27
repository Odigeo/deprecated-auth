require "spec_helper"

describe AuthenticationsController do
  describe "routing" do

    it "doesn't route to #index" do
      expect(get("/v1/authentications")).not_to be_routable
    end
    
    it "routes to #show" do
      expect(get("/v1/authentications/ea890a7f")).to route_to("authentications#show", id: "ea890a7f")
    end

    it "routes to #create" do
      expect(post("/v1/authentications")).to route_to("authentications#create")
    end

    it "doesn't route to #update" do
      expect(put("/v1/authentications/7ea890a7f")).not_to be_routable
    end
    

    it "routes to #destroy" do
      expect(delete("/v1/authentications/ea890a7f")).to route_to("authentications#destroy", id: "ea890a7f")
    end

    it "routes to #cleanup" do
      expect(put("/v1/authentications/cleanup")).to route_to("authentications#cleanup")
    end

  end
end

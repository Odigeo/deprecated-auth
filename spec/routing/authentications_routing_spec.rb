require "spec_helper"

describe AuthenticationsController do
  describe "routing" do

    it "doesn't route to #index" do
      get("/v1/authentications").should_not be_routable
    end
    
    it "routes to #show" do
      get("/v1/authentications/ea890a7f").should route_to("authentications#show", id: "ea890a7f")
    end

    it "routes to #create" do
      post("/v1/authentications").should route_to("authentications#create")
    end

    it "doesn't route to #update" do
      put("/v1/authentications/7ea890a7f").should_not be_routable
    end
    

    it "routes to #destroy" do
      delete("/v1/authentications/ea890a7f").should route_to("authentications#destroy", id: "ea890a7f")
    end

  end
end

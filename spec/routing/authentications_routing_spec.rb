require "spec_helper"

describe AuthenticationsController do
  describe "routing" do

    it "routes to #index" do
      get("/v1/authentications").should route_to("authentications#index")
    end
    
    it "routes to #show" do
      get("/v1/authentications/ea890a7f").should route_to("authentications#show", id: "ea890a7f")
    end

    it "routes to #create" do
      post("/v1/authentications").should route_to("authentications#create")
    end

    it "routes to #destroy" do
      delete("/v1/authentications/ea890a7f").should route_to("authentications#destroy", id: "ea890a7f")
    end

  end
end

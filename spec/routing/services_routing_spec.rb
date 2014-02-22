require "spec_helper"

describe ServicesController do
  describe "routing" do

    it "routes to #index" do
      get("/v1/services").should route_to("services#index")
    end

    it "routes to #show" do
      get("/v1/services/1").should route_to("services#show", :id => "1")
    end

    it "should not route to #create" do
      post("/v1/services").should_not be_routable
    end

    it "should not route to #update" do
      put("/v1/services/1").should_not be_routable
    end

    it "should not route to #destroy" do
      delete("/v1/services/1").should_not be_routable
    end

    it "routes to #resources to retrieve the service's resources" do
      get("/v1/services/1/resources").should route_to("services#resources", id: "1")
    end

    it "should not to #resources to create a new resource" do
      post("/v1/services/1/resources").should_not be_routable
    end

  end
end

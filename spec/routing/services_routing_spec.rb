require "spec_helper"

describe ServicesController do
  describe "routing" do

    it "routes to #index" do
      get("/v1/services").should route_to("services#index")
    end

    it "routes to #show" do
      get("/v1/services/1").should route_to("services#show", :id => "1")
    end

    it "routes to #create" do
      post("/v1/services").should route_to("services#create")
    end

    it "routes to #update" do
      put("/v1/services/1").should route_to("services#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/v1/services/1").should route_to("services#destroy", :id => "1")
    end

    it "routes to #resources to retrieve the service's resources" do
      get("/v1/services/1/resources").should route_to("services#resources", id: "1")
    end

    it "routes to #resources to create a new resource" do
      post("/v1/services/1/resources").should route_to("services#resource_create", id: "1")
    end

  end
end

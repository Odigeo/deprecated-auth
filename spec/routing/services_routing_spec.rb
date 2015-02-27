require "spec_helper"

describe ServicesController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/v1/services")).to route_to("services#index")
    end

    it "routes to #show" do
      expect(get("/v1/services/1")).to route_to("services#show", :id => "1")
    end

    it "should not route to #create" do
      expect(post("/v1/services")).not_to be_routable
    end

    it "should not route to #update" do
      expect(put("/v1/services/1")).not_to be_routable
    end

    it "should not route to #destroy" do
      expect(delete("/v1/services/1")).not_to be_routable
    end

    it "routes to #resources to retrieve the service's resources" do
      expect(get("/v1/services/1/resources")).to route_to("services#resources", id: "1")
    end

    it "should not to #resources to create a new resource" do
      expect(post("/v1/services/1/resources")).not_to be_routable
    end

  end
end

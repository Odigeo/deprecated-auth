require "spec_helper"

describe RolesController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/v1/roles")).to route_to("roles#index")
    end

    it "routes to #show" do
      expect(get("/v1/roles/1")).to route_to("roles#show", :id => "1")
    end

    it "routes to #create" do
      expect(post("/v1/roles")).to route_to("roles#create")
    end

    it "routes to #update" do
      expect(put("/v1/roles/1")).to route_to("roles#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/v1/roles/1")).to route_to("roles#destroy", :id => "1")
    end

    it "routes to #api_users" do
      expect(get("/v1/roles/1/api_users")).to route_to("roles#api_users", :id => "1")
    end

    it "routes to #groups" do
      expect(get("/v1/roles/1/groups")).to route_to("roles#groups", :id => "1")
    end

    it "routes to #rights" do
      expect(get("/v1/roles/1/rights")).to route_to("roles#rights", :id => "1")
    end

    it "routes to #connect to connect to another resource" do
      expect(put("/v1/roles/1/connect")).to route_to("roles#connect", id: "1")
    end

    it "routes to #disconnect to disconnect from a connected resource" do
      expect(delete("/v1/roles/1/connect")).to route_to("roles#disconnect", id: "1")
    end

  end
end

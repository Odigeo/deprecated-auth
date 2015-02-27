require "spec_helper"

describe GroupsController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/v1/groups")).to route_to("groups#index")
    end

    it "routes to #show" do
      expect(get("/v1/groups/1")).to route_to("groups#show", :id => "1")
    end

    it "routes to #create" do
      expect(post("/v1/groups")).to route_to("groups#create")
    end

    it "routes to #update" do
      expect(put("/v1/groups/1")).to route_to("groups#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/v1/groups/1")).to route_to("groups#destroy", :id => "1")
    end

    it "routes to #api_users" do
      expect(get("/v1/groups/1/api_users")).to route_to("groups#api_users", :id => "1")
    end

    it "routes to #roles" do
      expect(get("/v1/groups/1/roles")).to route_to("groups#roles", :id => "1")
    end

    it "routes to #rights" do
      expect(get("/v1/groups/1/rights")).to route_to("groups#rights", :id => "1")
    end

    it "routes to #connect to connect to another resource" do
      expect(put("/v1/groups/1/connect")).to route_to("groups#connect", id: "1")
    end

    it "routes to #disconnect to disconnect from a connected resource" do
      expect(delete("/v1/groups/1/connect")).to route_to("groups#disconnect", id: "1")
    end

  end
  
end

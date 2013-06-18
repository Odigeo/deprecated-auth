require "spec_helper"

describe GroupsController do
  describe "routing" do

    it "routes to #index" do
      get("/v1/groups").should route_to("groups#index")
    end

    it "routes to #show" do
      get("/v1/groups/1").should route_to("groups#show", :id => "1")
    end

    it "routes to #create" do
      post("/v1/groups").should route_to("groups#create")
    end

    it "routes to #update" do
      put("/v1/groups/1").should route_to("groups#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/v1/groups/1").should route_to("groups#destroy", :id => "1")
    end

    it "routes to #api_users" do
      get("/v1/groups/1/api_users").should route_to("groups#api_users", :id => "1")
    end

    it "routes to #roles" do
      get("/v1/groups/1/roles").should route_to("groups#roles", :id => "1")
    end

    it "routes to #rights" do
      get("/v1/groups/1/rights").should route_to("groups#rights", :id => "1")
    end

    it "routes to #connect to connect to another resource" do
      put("/v1/groups/1/connect").should route_to("groups#connect", id: "1")
    end

    it "routes to #disconnect to disconnect from a connected resource" do
      delete("/v1/groups/1/connect").should route_to("groups#disconnect", id: "1")
    end

  end
  
end

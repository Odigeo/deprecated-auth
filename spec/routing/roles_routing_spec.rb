require "spec_helper"

describe RolesController do
  describe "routing" do

    it "routes to #index" do
      get("/v1/roles").should route_to("roles#index")
    end

    it "routes to #show" do
      get("/v1/roles/1").should route_to("roles#show", :id => "1")
    end

    it "routes to #create" do
      post("/v1/roles").should route_to("roles#create")
    end

    it "routes to #update" do
      put("/v1/roles/1").should route_to("roles#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/v1/roles/1").should route_to("roles#destroy", :id => "1")
    end

    it "routes to #api_users" do
      get("/v1/roles/1/api_users").should route_to("roles#api_users", :id => "1")
    end

    it "routes to #groups" do
      get("/v1/roles/1/groups").should route_to("roles#groups", :id => "1")
    end

    it "routes to #rights" do
      get("/v1/roles/1/rights").should route_to("roles#rights", :id => "1")
    end

    it "routes to #connect to connect to another resource" do
      put("/v1/roles/1/connect").should route_to("roles#connect", id: "1")
    end

    it "routes to #disconnect to disconnect from a connected resource" do
      delete("/v1/roles/1/connect").should route_to("roles#disconnect", id: "1")
    end

  end
end

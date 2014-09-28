require "spec_helper"

describe ApiUsersController do
  describe "routing" do

    it "routes to #index" do
      get("/v1/api_users").should route_to("api_users#index")
    end
    
    it "routes to #show" do
      get("/v1/api_users/123").should route_to("api_users#show", id: "123")
    end

    it "routes to #create" do
      post("/v1/api_users").should route_to("api_users#create")
    end

    it "routes to #update" do
      put("/v1/api_users/123").should route_to("api_users#update", id: "123")
    end

    it "routes to #destroy" do
      delete("/v1/api_users/123").should route_to("api_users#destroy", id: "123")
    end

    it "routes to #authentications" do
      get("/v1/api_users/1/authentications").should route_to("api_users#authentications", id: "1")
    end

    it "routes to #roles" do
      get("/v1/api_users/1/roles").should route_to("api_users#roles", id: "1")
    end

    it "routes to #groups" do
      get("/v1/api_users/1/groups").should route_to("api_users#groups", id: "1")
    end

    it "routes to #rights" do
      get("/v1/api_users/1/rights").should route_to("api_users#rights", id: "1")
    end

    it "routes to #connect to connect to another resource" do
      put("/v1/api_users/1/connect").should route_to("api_users#connect", id: "1")
    end

    it "routes to #disconnect to disconnect from a connected resource" do
      delete("/v1/api_users/1/connect").should route_to("api_users#disconnect", id: "1")
    end

  end
end

require "spec_helper"

describe ApiUsersController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/v1/api_users")).to route_to("api_users#index")
    end
    
    it "routes to #show" do
      expect(get("/v1/api_users/123")).to route_to("api_users#show", id: "123")
    end

    it "routes to #create" do
      expect(post("/v1/api_users")).to route_to("api_users#create")
    end

    it "routes to #update" do
      expect(put("/v1/api_users/123")).to route_to("api_users#update", id: "123")
    end

    it "routes to #destroy" do
      expect(delete("/v1/api_users/123")).to route_to("api_users#destroy", id: "123")
    end

    it "routes to #authentications" do
      expect(get("/v1/api_users/1/authentications")).to route_to("api_users#authentications", id: "1")
    end

    it "routes to #roles" do
      expect(get("/v1/api_users/1/roles")).to route_to("api_users#roles", id: "1")
    end

    it "routes to #groups" do
      expect(get("/v1/api_users/1/groups")).to route_to("api_users#groups", id: "1")
    end

    it "routes to #rights" do
      expect(get("/v1/api_users/1/rights")).to route_to("api_users#rights", id: "1")
    end

    it "routes to #connect to connect to another resource" do
      expect(put("/v1/api_users/1/connect")).to route_to("api_users#connect", id: "1")
    end

    it "routes to #disconnect to disconnect from a connected resource" do
      expect(delete("/v1/api_users/1/connect")).to route_to("api_users#disconnect", id: "1")
    end

  end
end

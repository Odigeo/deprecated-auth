require "spec_helper"

describe CleanupController do
  describe "routing" do

    it "routes to #cleanup" do
      put("/cleanup").should route_to("cleanup#update")
    end

  end
end

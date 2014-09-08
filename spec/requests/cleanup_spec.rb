require 'spec_helper'

describe "/v1/authentications/cleanup (for purging old authentications from the DB)" do

  it "should return a 204" do
    permit_with 200
    Authentication.delete_all
    AuthenticationShadow.delete_all
    create :authentication, expires_at: 1.year.ago.utc
    create :authentication, expires_at: 1.month.ago.utc
    create :authentication, expires_at: 2.days.ago.utc
    create :authentication, expires_at: 2.hours.ago.utc        # Keep this one
    create :authentication, expires_at: 58.minutes.ago.utc     # And this one
    create :authentication, expires_at: 1.hour.from_now.utc    # And this one
    put "/v1/authentications/cleanup", {}, {'HTTP_ACCEPT' => "application/json",
                                            "X-API-Token" => "boy-is-this-fake"}
    response.status.should be(204)
    Authentication.count.should == 3
  end
  
end

require 'spec_helper'

describe "/v1/authentications/cleanup (for purging old authentications from the DB)" do

  it "should return a 200 and statistics" do
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
    expect(response.status).to be(200)
    expect(Authentication.count).to eq(3)
    expect(response.body).to eq('{"cleaned_up":3,"remaining":3}')
  end
  
  it "should handle the case where nothing is purged" do
    permit_with 200
    Authentication.delete_all
    AuthenticationShadow.delete_all
    put "/v1/authentications/cleanup", {}, {'HTTP_ACCEPT' => "application/json",
                                            "X-API-Token" => "boy-is-this-fake"}
    expect(response.status).to be(200)
    expect(Authentication.count).to eq(0)
    expect(response.body).to eq('{"cleaned_up":0,"remaining":0}')
  end

end

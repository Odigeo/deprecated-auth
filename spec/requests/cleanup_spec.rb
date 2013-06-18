require 'spec_helper'

describe "/cleanup (for purging old authentications from the DB)" do

  it "should return a 204" do
    Authentication.destroy_all
    ApiUser.destroy_all
    create :authentication, expires_at: 1.year.ago.utc
    create :authentication, expires_at: 1.month.ago.utc
    create :authentication, expires_at: 1.day.ago.utc
    create :authentication, expires_at: 2.hours.ago.utc
    create :authentication, expires_at: 58.minutes.ago.utc     # Keep this one
    create :authentication, expires_at: 1.hour.from_now.utc    # And this one
    put "/cleanup", {}, {'HTTP_ACCEPT' => "application/json"}
    Authentication.count.should == 2
    response.status.should be(204)
    Authentication.destroy_all
    ApiUser.destroy_all
  end
  
end

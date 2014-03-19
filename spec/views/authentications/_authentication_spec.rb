require 'spec_helper'

describe "authentications/_authentication" do
      
  before :each do
    Authentication.destroy_all
    ApiUser.destroy_all
    original = create(:authentication)
    group1 = create(:group, name: "Superusers")
    group2 = create(:group, name: "Some Other Group")
    original.api_user.groups << group1
    original.api_user.groups << group2
    @api_user_name = original.api_user.username
    @api_user_id = original.api_user.id
    render partial: "authentications/authentication", locals: {authentication: original}
    @json = JSON.parse(rendered)
    @auth = @json['authentication']
    @links = @auth['_links'] rescue {}
  end

      
  it "has a named root" do
    @auth.should_not == nil
  end

  it "should have two hyperlinks" do
    @links.size.should == 2
  end

  it "should have a self hyperlink" do
    @links.should be_hyperlinked('self', /authentications/)
  end

  it "should have a creator hyperlink" do
    @links.should be_hyperlinked('creator', /api_users/)
  end

  it "should have a string token" do
    @auth['token'].should be_a String
  end

  it "should have a max_age in seconds" do
    @auth['max_age'].should be_an Integer
  end

  it "should have a created_at time" do
    @auth['created_at'].should be_a String
  end

  it "should have an expired_at time" do
    @auth['expires_at'].should be_a String
  end
  
  it "should have an ApiUser username" do
    @auth['username'].should == @api_user_name
  end

  it "should have a numerical ApiUser ID" do
    @auth['user_id'].should == @api_user_id
  end

  it "should have an array of Group names" do
    @auth['group_names'].should == ["Superusers", "Some Other Group"]
  end

end

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
    assign :right, create(:right, app: "quux", context: "*")
    assign :group_names, ["Superusers", "Some Other Group"]
    render partial: "authentications/authentication", locals: {authentication: original}
    @json = JSON.parse(rendered)
    @auth = @json['authentication']
    @links = @auth['_links'] rescue {}
  end

      
  it "has a named root" do
    expect(@auth).not_to eq(nil)
  end

  it "should have two hyperlinks" do
    expect(@links.size).to eq(2)
  end

  it "should have a self hyperlink" do
    expect(@links).to be_hyperlinked('self', /authentications/)
  end

  it "should have a creator hyperlink" do
    expect(@links).to be_hyperlinked('creator', /api_users/)
  end

  it "should have a string token" do
    expect(@auth['token']).to be_a String
  end

  it "should have a max_age in seconds" do
    expect(@auth['max_age']).to be_an Integer
  end

  it "should have a created_at time" do
    expect(@auth['created_at']).to be_a String
  end

  it "should have an expired_at time" do
    expect(@auth['expires_at']).to be_a String
  end
  
  it "should have an ApiUser username" do
    expect(@auth['username']).to eq(@api_user_name)
  end

  it "should have a numerical ApiUser ID" do
    expect(@auth['user_id']).to eq(@api_user_id)
  end

  it "should have a right" do
    expect(@auth['right']).to eq([{"app"=>"quux", "context"=>"*"}])
  end

  it "should have an array of Group names" do
    expect(@auth['group_names']).to eq(["Superusers", "Some Other Group"])
  end

end

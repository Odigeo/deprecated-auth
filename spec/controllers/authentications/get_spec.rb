require 'spec_helper'

describe AuthenticationsController do
  
  render_views
    
  describe "GET" do
    
    before :each do
      Authentication.destroy_all
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "whatever"
    end
    

    it "should return JSON" do
      get :show, id: "ea243542300fcbe", query: "serv:res:self:GET:*:*"
      response.content_type.should == "application/json"
    end
    
    it "should return a 200 when successful" do
      AuthenticationShadow.should_receive(:find_by_key).and_return(create :authentication_shadow)
      AuthenticationShadow.any_instance.stub(:authorized?).and_return(true)
      get :show, id: "ea243542300fcbe", query: "serv:res:self:GET:*:*"
      response.should render_template(partial: "_authentication", count: 1)
      response.content_type.should == "application/json"
      response.status.should == 200
    end
    
    it "should not require an X-API-Token" do
      request.headers['X-API-Token'] = nil
      AuthenticationShadow.should_receive(:find_by_key).and_return(create :authentication_shadow)
      AuthenticationShadow.any_instance.stub(:authorized?).and_return(true)
      get :show, id: "ea243542300fcbe", query: "serv:res:self:GET:*:*"
      response.content_type.should == "application/json"
      response.status.should == 200
    end

    it "should return a 400 if the client's authentication is unknown" do
      get :show, id: "something nonexistent", query: "serv:res:self:GET:*:*"
      response.content_type.should == "application/json"
      response.status.should == 400
    end

    it "should return a 419 if the client's authentication has expired" do
      get :show, id: create(:authentication, expires_at: 1.year.ago).token, query: "serv:res:self:GET:*:*"
      response.content_type.should == "application/json"
      response.status.should == 419
    end

    it "should return a 403 Forbidden if the client doesn't have authorization" do
      AuthenticationShadow.should_receive(:find_by_key).and_return(create :authentication_shadow)
      AuthenticationShadow.any_instance.stub(:authorized?).and_return(false)
      get :show, id: "ea243542300fcbe", query: "serv:res:self:GET:*:*"
      response.content_type.should == "application/json"
      response.status.should == 403
    end

    it "should return a 422 if the query arg is missing" do
      AuthenticationShadow.should_receive(:find_by_key).and_return(create :authentication_shadow)
      get :show, id: "ea243542300fcbe"
      response.content_type.should == "application/json"
      response.status.should == 422
    end
        
    it "should return a 422 if the query arg is blank" do
      AuthenticationShadow.should_receive(:find_by_key).and_return(create :authentication_shadow)
      get :show, id: "ea243542300fcbe", query: ""
      response.content_type.should == "application/json"
      response.status.should == 422
    end

    it "should return a 422 if the query arg is not in six parts" do
      AuthenticationShadow.should_receive(:find_by_key).and_return(create :authentication_shadow)
      get :show, id: "ea243542300fcbe", query: "foo:bar"
      response.content_type.should == "application/json"
      response.status.should == 422
    end
        
    it "should return a 200 if the client has authorization" do
      AuthenticationShadow.should_receive(:find_by_key).and_return(create :authentication_shadow)
      AuthenticationShadow.any_instance.stub(:authorized?).and_return(true)
      get :show, id: "ea243542300fcbe", query: "serv:res:self:GET:*:*"
      response.content_type.should == "application/json"
      response.status.should == 200
    end
    
    it "should return a complete resource" do
      AuthenticationShadow.should_receive(:find_by_key).and_return(create :authentication_shadow)
      AuthenticationShadow.any_instance.stub(:authorized?).and_return(true)
      get :show, id: "87e87ff086543ee0a", query: "serv:res:self:GET:*:*"
      response.content_type.should == "application/json"
      response.status.should == 200
      r = JSON.parse(response.body)
      r.should be_a Hash
    end
    
    it "should be cached exactly AUTHORIZATION_DURATION seconds" do
      AuthenticationShadow.should_receive(:find_by_key).and_return(create :authentication_shadow)
      AuthenticationShadow.any_instance.stub(:authorized?).and_return(true)
      get :show, id: "87e87ff086543ee0a", query: "serv:res:self:GET:*:*"
      response.content_type.should == "application/json"
      response.status.should == 200
      auth = JSON.parse(response.body)['authentication']
      expires_at = Time.parse(auth['expires_at'])
      cc = response.headers['Cache-Control']
      cc.should be_a String
      cc_s_maxage = (/s-maxage=([0-9]+)/.match cc)[1].to_i
      cc_s_maxage.should == AUTHORIZATION_DURATION
    end
    
    it "should be publicly cached" do
      AuthenticationShadow.should_receive(:find_by_key).and_return(create :authentication_shadow)
      AuthenticationShadow.any_instance.stub(:authorized?).and_return(true)
      get :show, id: "87e87ff086543ee0a", query: "serv:res:self:GET:*:*"
      response.content_type.should == "application/json"
      response.status.should == 200
      auth = JSON.parse(response.body)['authentication']
      cc = response.headers['Cache-Control']
      cc.should be_a String
      cc.should match /public/
    end
    
    it "should have a max-stale cache setting of 0" do
      AuthenticationShadow.should_receive(:find_by_key).and_return(create :authentication_shadow)
      AuthenticationShadow.any_instance.stub(:authorized?).and_return(true)
      get :show, id: "87e87ff086543ee0a", query: "serv:res:self:GET:*:*"
      response.content_type.should == "application/json"
      response.status.should == 200
      auth = JSON.parse(response.body)['authentication']
      cc = response.headers['Cache-Control']
      cc.should be_a String
      cc_max_stale = (/max-stale=([0-9]+)/.match cc)[1].to_i
      cc_max_stale.should == 0
    end


    describe "authentication attribute 'right'" do

      it "should include app and context from the Right, if authorized? returns one" do
        AuthenticationShadow.should_receive(:find_by_key).and_return(create :authentication_shadow)
        AuthenticationShadow.any_instance.stub(:authorized?).and_return(create :right, app: "foo", context: "*")
        get :show, id: "87e87ff086543ee0a", query: "serv:res:self:GET:foo:bar"
        response.content_type.should == "application/json"
        response.status.should == 200
        auth = JSON.parse(response.body)['authentication']
        auth['right'].should == [{"app"=>"foo", "context"=>"*"}]
      end
        
      it "should include an array as is, if authorized? returns one" do
        AuthenticationShadow.should_receive(:find_by_key).and_return(create :authentication_shadow)
        AuthenticationShadow.any_instance.stub(:authorized?).and_return([{app: 'x', context: 'y'},
                                                                         {app: 'z', context: '*'}])
        get :show, id: "87e87ff086543ee0a", query: "serv:res:self:GET:foo:bar"
        response.content_type.should == "application/json"
        response.status.should == 200
        auth = JSON.parse(response.body)['authentication']
        auth['right'].should == [{"app"=>"x", "context"=>"y"}, 
                                 {"app"=>"z", "context"=>"*"}]
      end
    end
      
  end

end

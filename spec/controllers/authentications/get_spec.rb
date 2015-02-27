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
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 200 when successful" do
      expect(AuthenticationShadow).to receive(:find_by_key).and_return(create :authentication_shadow)
      allow_any_instance_of(AuthenticationShadow).to receive(:authorized?).and_return(true)
      get :show, id: "ea243542300fcbe", query: "serv:res:self:GET:*:*"
      expect(response).to render_template(partial: "_authentication", count: 1)
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(200)
    end
    
    it "should not require an X-API-Token" do
      request.headers['X-API-Token'] = nil
      expect(AuthenticationShadow).to receive(:find_by_key).and_return(create :authentication_shadow)
      allow_any_instance_of(AuthenticationShadow).to receive(:authorized?).and_return(true)
      get :show, id: "ea243542300fcbe", query: "serv:res:self:GET:*:*"
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(200)
    end

    it "should return a 400 if the client's authentication is unknown" do
      get :show, id: "something nonexistent", query: "serv:res:self:GET:*:*"
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(400)
    end

    it "should return a 419 if the client's authentication has expired" do
      get :show, id: create(:authentication, expires_at: 1.year.ago).token, query: "serv:res:self:GET:*:*"
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(419)
    end

    it "should return a 403 Forbidden if the client doesn't have authorization" do
      expect(AuthenticationShadow).to receive(:find_by_key).and_return(create :authentication_shadow)
      allow_any_instance_of(AuthenticationShadow).to receive(:authorized?).and_return(false)
      get :show, id: "ea243542300fcbe", query: "serv:res:self:GET:*:*"
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(403)
    end

    it "should return a 422 if the query arg is missing" do
      expect(AuthenticationShadow).to receive(:find_by_key).and_return(create :authentication_shadow)
      get :show, id: "ea243542300fcbe"
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(422)
    end
        
    it "should return a 422 if the query arg is blank" do
      expect(AuthenticationShadow).to receive(:find_by_key).and_return(create :authentication_shadow)
      get :show, id: "ea243542300fcbe", query: ""
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(422)
    end

    it "should return a 422 if the query arg is not in six parts" do
      expect(AuthenticationShadow).to receive(:find_by_key).and_return(create :authentication_shadow)
      get :show, id: "ea243542300fcbe", query: "foo:bar"
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(422)
    end
        
    it "should return a 200 if the client has authorization" do
      expect(AuthenticationShadow).to receive(:find_by_key).and_return(create :authentication_shadow)
      allow_any_instance_of(AuthenticationShadow).to receive(:authorized?).and_return(true)
      get :show, id: "ea243542300fcbe", query: "serv:res:self:GET:*:*"
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(200)
    end
    
    it "should return a complete resource" do
      expect(AuthenticationShadow).to receive(:find_by_key).and_return(create :authentication_shadow)
      allow_any_instance_of(AuthenticationShadow).to receive(:authorized?).and_return(true)
      get :show, id: "87e87ff086543ee0a", query: "serv:res:self:GET:*:*"
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(200)
      r = JSON.parse(response.body)
      expect(r).to be_a Hash
    end
    
    it "should be cached exactly AUTHORIZATION_DURATION seconds" do
      expect(AuthenticationShadow).to receive(:find_by_key).and_return(create :authentication_shadow)
      allow_any_instance_of(AuthenticationShadow).to receive(:authorized?).and_return(true)
      get :show, id: "87e87ff086543ee0a", query: "serv:res:self:GET:*:*"
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(200)
      auth = JSON.parse(response.body)['authentication']
      expires_at = Time.parse(auth['expires_at'])
      cc = response.headers['Cache-Control']
      expect(cc).to be_a String
      cc_s_maxage = (/s-maxage=([0-9]+)/.match cc)[1].to_i
      expect(cc_s_maxage).to eq(AUTHORIZATION_DURATION)
    end
    
    it "should be publicly cached" do
      expect(AuthenticationShadow).to receive(:find_by_key).and_return(create :authentication_shadow)
      allow_any_instance_of(AuthenticationShadow).to receive(:authorized?).and_return(true)
      get :show, id: "87e87ff086543ee0a", query: "serv:res:self:GET:*:*"
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(200)
      auth = JSON.parse(response.body)['authentication']
      cc = response.headers['Cache-Control']
      expect(cc).to be_a String
      expect(cc).to match /public/
    end
    
    it "should have a max-stale cache setting of 0" do
      expect(AuthenticationShadow).to receive(:find_by_key).and_return(create :authentication_shadow)
      allow_any_instance_of(AuthenticationShadow).to receive(:authorized?).and_return(true)
      get :show, id: "87e87ff086543ee0a", query: "serv:res:self:GET:*:*"
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(200)
      auth = JSON.parse(response.body)['authentication']
      cc = response.headers['Cache-Control']
      expect(cc).to be_a String
      cc_max_stale = (/max-stale=([0-9]+)/.match cc)[1].to_i
      expect(cc_max_stale).to eq(0)
    end


    describe "authentication attribute 'right'" do

      it "should include app and context from the Right, if authorized? returns one" do
        expect(AuthenticationShadow).to receive(:find_by_key).and_return(create :authentication_shadow)
        allow_any_instance_of(AuthenticationShadow).to receive(:authorized?).and_return(create :right, app: "foo", context: "*")
        get :show, id: "87e87ff086543ee0a", query: "serv:res:self:GET:foo:bar"
        expect(response.content_type).to eq("application/json")
        expect(response.status).to eq(200)
        auth = JSON.parse(response.body)['authentication']
        expect(auth['right']).to eq([{"app"=>"foo", "context"=>"*"}])
      end
        
      it "should include an array as is, if authorized? returns one" do
        expect(AuthenticationShadow).to receive(:find_by_key).and_return(create :authentication_shadow)
        allow_any_instance_of(AuthenticationShadow).to receive(:authorized?).and_return([{app: 'x', context: 'y'},
                                                                         {app: 'z', context: '*'}])
        get :show, id: "87e87ff086543ee0a", query: "serv:res:self:GET:foo:bar"
        expect(response.content_type).to eq("application/json")
        expect(response.status).to eq(200)
        auth = JSON.parse(response.body)['authentication']
        expect(auth['right']).to eq([{"app"=>"x", "context"=>"y"}, 
                                 {"app"=>"z", "context"=>"*"}])
      end
    end
      
  end

end

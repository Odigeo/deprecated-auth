require 'spec_helper'

describe RolesController do
  
  render_views
  
  describe "POST" do
    
    before :each do
      permit_with 200
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "incredibly-fake!"
      @args = build(:role).attributes
    end
    
    
    it "should return JSON" do
      post :create, @args
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      post :create, @args
      expect(response.status).to eq(400)
    end
    
    #
    # Uncomment this test as soon as there is one or more DB attributes that define
    # the uniqueness of a record.
    #
    # it "should return a 422 if the role already exists" do
    #   post :create, @args
    #   response.status.should == 201
    #   response.content_type.should == "application/json"
    #   post :create, @args
    #   response.status.should == 422
    #   response.content_type.should == "application/json"
    #   JSON.parse(response.body).should == {"_api_error" => ["Role already exists"]}
    # end

    #
    # Uncomment this test as soon as there is one or more DB attributes that need
    # validating.
    #
    # it "should return a 422 when there are validation errors" do
    #   post :create, @args.merge(:locale => "nix-DORF")
    #   response.status.should == 422
    #   response.content_type.should == "application/json"
    #   JSON.parse(response.body).should == {"locale"=>["ISO language code format required ('de-AU')"]}
    # end
                
    it "should return a 201 when successful" do
      post :create, @args
      expect(response.status).to eq(201)
    end

    it "should contain a Location header when successful" do
      post :create, @args
      expect(response.headers['Location']).to be_a String
    end

    it "should return the new resource in the body when successful" do
      post :create, @args
      expect(response).to render_template(partial: '_role', count: 1)
      expect(response.body).to be_a String
    end
    
    it "should not allow the indestructible flag to be set" do
      post :create, name: "Ze Foo Role", description: "A comment", indestructible: true
      u = JSON.parse(response.body)['role']
      expect(u['name']).to eq("Ze Foo Role")
      expect(u['indestructible']).to eq(nil)
    end

    it "should allow documentation to be set" do
      post :create, @args.merge(documentation_href: "http://acme.com")
      u = JSON.parse(response.body)['role']
      expect(u['_links']['documentation']).to eq({"href"=>"http://acme.com", "type"=>"text/html"})
    end
  end
  
end

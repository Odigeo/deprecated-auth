require 'spec_helper'

describe RightsController do
  
  render_views

  describe "PUT" do
    
    before :each do
      permit_with 200
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "incredibly-fake!"
      @u = create :right
      @args = @u.attributes
    end

    
    it "should render the object partial" do
      put :update, @args
      expect(response).to render_template(partial: '_right', count: 1)
    end

    it "should return JSON" do
      put :update, @args
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      put :update, @args
      expect(response.status).to eq(400)
    end

    it "should return a 404 if the resource can't be found" do
      put :update, id: -1
      expect(response.status).to eq(404)
      expect(response.content_type).to eq("application/json")
    end

    it "should return a 422 when resource properties are missing (all must be set simultaneously)" do
      put :update, id: @u.id
      expect(response.status).to eq(422)
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 422 when there are validation errors" do
      put :update, @args.merge('hyperlink' => "Not correct")
      expect(response.status).to eq(422)
      expect(response.content_type).to eq("application/json")
      expect(JSON.parse(response.body)).to eq({"hyperlink"=>["may only contain the characters a-z, 0-9, and underscores, and must start with a lowercase letter"]}) 
    end

    it "should return a 409 when there is an update conflict" do
      @u.save
      put :update, @args.merge('lock_version' => 10)
      expect(response.status).to eq(409)
    end
        
    it "should return a 200 when successful" do
      put :update, @args
      expect(response.status).to eq(200)
    end

    describe "with render_views" do
      render_views
      it "should return the updated resource in the body when successful" do
        put :update, @args
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to be_a Hash
      end
    end

    it "should alter the resource when successful" do
      expect(@u.description).to eq("This is a description of the Right.")
      @args['description'] = "Zalagadoola"
      put :update, @args, lock_version: 0
      expect(response.status).to eq(200)
      @u.reload
      expect(@u.description).to eq("Zalagadoola")
    end

  end
  
end
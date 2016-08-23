require 'spec_helper'

describe Users::UserProfilesController, :type => :controller do

  # Can't find a test that you expected to be living here? Try checking the API test suite.
  
  describe "#show" do

    context "when user does not have username" do

      let(:user) do
        u = FactoryGirl.create(:user, :username => nil)
        u.username = nil
        u.save
        u
      end

      context "when /users/1" do

        before do
          get :show, :id => user.id
        end

        it "username is not set" do
          user.username.should be_nil
        end

        it "responds with 200" do
          response.status.should eq 200
        end
      end

      context "with /:id" do
        it "responds with 200" do
          response.status.should eq 200
        end
      end
    end

    describe "when user has username" do

      let(:user) { u = FactoryGirl.create(:user) }

      before :each do
        get :show, :id => user.id
      end

      context "with /:id" do
        it "redirects_to /:username" do
          response.status.should redirect_to("/#{user.username}")
        end
      end

      context "with /users/1" do        
        it "responds with 301 (Moved Permanently)" do
          response.status.should eq 301
        end
      end

      context "with /users/username" do
        it "redirects_to /user/:id" do
          response.status.should redirect_to("/#{user.username}")
        end
        it "responds with 301 (Moved Permanently)" do
          response.status.should eq 301
        end
      end
    end

    context "when user does not exist" do

      context "when /users/[id]" do

        before do
          get :show, :id => 1009238023
        end

        it "responds with 404" do
          response.status.should eq 404
        end

        it "redirects to root" do
          route_to("root")
        end
      end

      context "when /users/[username]" do

        before do
          get :show, :username => "does-not-exist"
        end

        it "responds with 404" do
          response.status.should eq 404
        end

        it "redirects to root" do
          route_to("root")
        end
      end

    end
  end
end
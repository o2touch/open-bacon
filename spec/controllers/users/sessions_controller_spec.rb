require 'spec_helper'

describe Users::SessionsController, :type => :controller do

  describe '#new' do

    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context 'invalid details' do

      before :each do
        @newuser = FactoryGirl.create(:user)
        @params = {
            :email => @newuser.email,
            :password => "wrongpassword"
        }
        
      end

      describe "as HTML" do

        before :each do
          post :create, format: :html, user: @params
        end

        it 'does not login' do
          warden.authenticated?(:user).should == false
        end

        it 'renders to #new' do
          response.should be_successful
          response.should render_template("new")
        end
      end

      describe "as JSON" do
        
        before :each do
          post :create, format: :json, user: @params
        end

        it 'does not login' do
          warden.authenticated?(:user).should == false
        end

        it 'returns unauthorized code' do
          response.status.should == 401
        end
      end
    end

    context 'resource has NO_LOGIN role' do
      before :each do
        @new_user = FactoryGirl.create(:user)
        @user_params = {
          :email => @new_user.email,
          :password => @new_user.password
          #:password => "not the password"
        }
        @new_user.add_role RoleEnum::NO_LOGIN
      end

      describe "as HTML" do

        before :each do
          post :create, format: :html, user: @user_params
        end

        it 'does not login' do
          warden.authenticated?(:user).should == false
        end

        it 'renders to #new'
      end

      describe "as JSON" do
        
        before :each do
          post :create, format: :json, user: @user_params
        end

        it 'does not login' do
          warden.authenticated?(:user).should == false
        end

        it 'returns unauthorized code'
      end
    end


    context 'valid details' do

      before :each do
        @newuser = FactoryGirl.create(:user)
        @userparams = {
            :email => @newuser.email,
            :password => @newuser.password
        }
        
      end

      describe "as HTML" do

        before :each do
          post :create, format: :html, user: @userparams
        end

        it 'logs in' do
          warden.authenticated?(:user).should == true
        end

        # it 'redirects to root_path' do
        #   response.should redirect_to root_path
        # end
      end

      describe "as JSON" do
        
        before :each do
          post :create, format: :json, user: @userparams
        end

        it 'logs in' do
          warden.authenticated?(:user).should == true
        end

        it 'returns sucess' do
          response.status.should == 200
        end
      end
    end

  end
end
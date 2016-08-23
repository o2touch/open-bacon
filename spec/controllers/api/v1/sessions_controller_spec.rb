require 'spec_helper'

describe Api::V1::M::SessionsController do
  render_views

  let(:user) { FactoryGirl.create :user }

  describe '#create', type: :api do 

    context 'with valid credentials' do
      before :each do
        post :create, email: user.email, password: "password", format: :json
        user.reload
      end

      it 'is successful' do
        response.status.should eq(200)
      end

      it 'generates and saves an authentication token' do
        user.authentication_token.should_not be_nil
      end

      it 'returns the authentication token' do
        JSON.parse(response.body)["auth_token"].should eq(user.authentication_token)
      end
    end

    context 'with missing credentials' do
      shared_examples_for 'missing credentials' do |email, password|
        before :each do
          post :create, email: email, password: password, format: :json
        end

        it 'returns 400' do
          response.status.should eql(400)
        end

        it 'returns helpful json' do
          expected_response = {"message" => "Missing credentials"}
          JSON.parse(response.body).should eq expected_response
        end
      end

      context 'with missing password' do
        it_behaves_like "missing credentials", "email@address.com", ""
      end

      context 'with missing email' do
        it_behaves_like "missing credentials", "", "password"
      end

      context 'with missing password and email' do
        it_behaves_like "missing credentials", "", ""
      end
    end

    context 'with invalid credentials' do
      shared_examples_for 'invalid credentials' do |email, password|
        before :each do
          post :create, email: email, password: password, format: :json
        end

        it 'returns 401' do
          response.status.should eq 401
        end

        it 'returns helpful json' do
          expected_response = {"message" => "Invalid credentials"}
          JSON.parse(response.body).should eq expected_response
        end
      end

      context 'with invalid password' do
        it_behaves_like "invalid credentials", "test1@test.com", "not the password"
      end
      context 'with inavlid email' do
        it_behaves_like "invalid credentials", "invalid@email.com", "Test Password"
      end
      context 'with invalid password and email' do
        it_behaves_like "invalid credentials", "invalid@email.com", "not the password"
      end
    end
  end

  describe '#destroy', type: :api do
    it 'invalidates the authentication token' do
      user.ensure_authentication_token!
      user.reload

      lambda do
        request.env['X-AUTH-TOKEN'] = user.authentication_token
        post :destroy, format: :json
        user.reload
      end.should change(user, :authentication_token)
    end

    it 'returns 200' do
      request.env['X-AUTH-TOKEN'] = user.authentication_token
      post :destroy, format: :json
      response.status.should eq 200
    end
  end
end

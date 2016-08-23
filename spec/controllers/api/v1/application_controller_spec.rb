require 'spec_helper'

describe Api::V1::ApplicationController do
	before :each do
		@user = FactoryGirl.create :user
    request.env['X-AUTH-TOKEN'] = @user.authentication_token
	end

	context 'checking authentication for a request' do
		controller(Api::V1::ApplicationController) do
			skip_authorization_check only: :index
			def index
				render text: "hi"
			end
		end

		it 'returns 401 if unauthenticated' do
			request.env['X-AUTH-TOKEN'] = nil

			get :index
			response.status.should eq 401
		end

		it 'fetched the auth header and sets a param for devise' do
			get :index
			controller.params[:auth_token].should eq @user.authentication_token
		end

		it 'allows the request to continue if authenticated' do
			get :index
			response.status.should eq 200
		end
	end

	context 'handling record not found errors' do
		controller(Api::V1::ApplicationController) do
			def index
				raise ActiveRecord::RecordNotFound
			end
		end

		it 'returns 404' do
			get :index
			response.status.should eq 404
		end
	end

	context 'handling routing errors' do
		controller(Api::V1::ApplicationController) do
			def index
				raise ActionController::RoutingError.new("you got mad boid")
			end
		end

		it 'returns 404 for json requests' do
			get :index, format: :json
			response.status.should eq 404
		end

		it 'returns 302 redirects dickheads who accidenatly type /api/NOT_A_PAGE' do
			get :index, format: :html
			response.status.should eq 302
		end
	end

	context 'handling cancan access denied errors' do
		controller(Api::V1::ApplicationController) do
			def index
				authorize! :destroy, User.find(1)
			end
		end

		it 'returns 401' do
			get :index
		end
	end
end
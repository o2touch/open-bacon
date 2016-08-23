require 'spec_helper'

describe PowerTokensController, :type => :controller  do
	describe '#show' do
		context 'with active power token, without user' do
			before :each do
				@token = "TIMTOKEN"
				@path = "PATH"

				@power_token = double("power token")
				@power_token.should_receive(:redirect_path).and_return(@path)
				@power_token.should_receive(:user).and_return(nil)

				PowerToken.should_receive(:find_active_token).with(@token).and_return(@power_token)

				get :show, token: @token, format: :html
			end

			it 'returns 302' do
				response.status.should eq(302)
			end
			it 'redirects to token path' do
				response.location.should eq("http://test.host#{@path}")
			end
		end

		context 'with active power token, with user' do
			before :each do
				@token = "TIMTOKEN"
				@path = "PATH"
				@user = FactoryGirl.build :user

				@power_token = double("power token")
				@power_token.should_receive(:redirect_path).and_return(@path)
				@power_token.should_receive(:user).twice.and_return(@user)

				PowerToken.should_receive(:find_active_token).with(@token).and_return(@power_token)

				get :show, token: @token, format: :html
			end

			it 'returns 302' do
				response.status.should eq(302)
			end
			it 'redirects to token path' do
				response.location.should eq("http://test.host#{@path}")
			end
		end

		context 'with no active power token' do
			it 'returns 404' do
				PowerToken.should_receive(:find_active_token).and_return(nil)
				get :show, token: "lskjdfls"
				response.status.should eq(404)
			end
		end
	end	
end
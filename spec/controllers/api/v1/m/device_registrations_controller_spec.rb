require 'spec_helper'

describe Api::V1::M::DeviceRegistrationsController do

	before :each do
	    # This stubs out the before_filter of application_controller
	    Api::V1::M::DeviceRegistrationsController.any_instance.stub(:log_user_activity)
	 end

	describe '#create' do
		def do_create(attrs={})
			attrs[:token] = "TOKEN" unless attrs.has_key? :token
			post :create, device: attrs, format: :json
		end

		before :each do
			signed_in
		end

		context 'authentication' do
			it 'is performed' do
				signed_out
				do_create
				response.status.should eq(401)
			end
		end

		context 'functionality' do
			it 'does shit' do
				user = double("user")
				signed_in user

				token = "TOKEN"
				DeviceRegistrationsService.should_receive(:register_device).with(user, token, {app_instance_id: 1})
				do_create(token: token)
				response.status.should eq(201)
			end

			it 'errors if no device token supplied' do
				attrs = { token: nil }
				do_create(attrs)
				response.status.should eq(422)
			end

		end
	end

	describe '#destroy' do
		def do_destroy(token="TOKEN")
			post :destroy, token: token, format: :json
		end

		before :each do
			@user = FactoryGirl.build :user	
			signed_in @user
		end

		context 'authentication' do
			it 'is performed' do
				signed_out
				do_destroy
				response.status.should eq(401)
			end
		end

		context 'functionality' do
			it 'does shit' do
				token = "TOKEN"
				@user.should_receive(:mobile_devices).and_return([double(token: token)])
				DeviceRegistrationsService.should_receive(:logout_device).with(token)
				do_destroy token
				response.status.should eq(204)
			end

			it '404s if the user don\'t got no device with dat token, innit fam' do
				# user has no devices...
				do_destroy
				response.status.should eq(404)
			end

		end
	end
end
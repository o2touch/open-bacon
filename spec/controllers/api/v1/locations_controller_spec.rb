require 'spec_helper'

describe Api::V1::LocationsController do

	before :each do
	    # This stubs out the before_filter of application_controller
	    Api::V1::LocationsController.any_instance.stub(:log_user_activity)
	 end

	describe '#index' do
		def do_index(resource="team", id=1)
			get :index, format: :json, resource: resource, resource_id: id
		end

		before :each do
			@team = FactoryGirl.build(:team)
			Team.stub(find: @team)
			fake_ability
			signed_in
		end

		context 'authentication' do
			it 'is performed' do
				signed_out
				do_index
				response.status.should eq(401)
			end
		end

		context 'authorization' do
			it 'read is checked and returns 401 if not authed' do
				mock_ability(read: :fail)
				do_index
				response.status.should eq(401)
			end

			it 'read is checkout and returns 200 if authed' do
				mock_ability(read: :pass)
				do_index
				response.status.should eq(200)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				Team.unstub(:find)
				do_index
				response.status.should eq(404)
			end

			it 'returns 422 if resource != team, or league' do
				do_index("alskdjfals", 1)
				response.status.should eq(422)
			end
		end
	end	
end
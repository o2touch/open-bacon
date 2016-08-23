require 'spec_helper'

describe Api::V1::PointsAdjustmentsController do

	before :each do
	    # This stubs out the before_filter of application_controller
	    Api::V1::PointsAdjustmentsController.any_instance.stub(:log_user_activity)
	 end
	 
	describe '#create' do
		def do_create(custom_attrs={})
			attrs = { team_id: 4, adjustment: -7, desc: "fuck you all" }
			attrs.merge! custom_attrs
			post :create, format: :json, api_v1_division_id: 5, points_adjustment: attrs
		end

		before :each do
			@division = FactoryGirl.create :division_season
			@team = FactoryGirl.create :team
			TeamDSService.add_team(@division, @team)

			DivisionSeason.stub(find: @division)
			Team.stub(find_by_id: @team)
			fake_ability
			signed_in
		end

		context 'authentication' do
			it 'is performed' do
				signed_out
				do_create
				response.status.should eq(401)
			end
		end

		context 'authorization' do
			it 'read is checked and returns 401 if not authed' do
				mock_ability(update: :fail)
				do_create
				response.status.should eq(401)
			end

			it 'read is checkout and returns 200 if authed' do
				mock_ability(update: :pass)
				do_create
				response.status.should eq(200)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				DivisionSeason.unstub :find
				do_create
				response.status.should eq(404)
			end
			it 'returns 422 if no team provided' do
				Team.unstub :find_by_id
				do_create
				response.status.should eq(422)
			end
		end

		context 'functionality' do
			it 'does shit' do
				PointsAdjustment.should_receive(:create!)
				do_create
				response.status.should eq(200)
			end

			it 'errors if div does not track results' do
				@division.track_results = false
				do_create
				response.status.should eq(422)
			end
		end
	end
end
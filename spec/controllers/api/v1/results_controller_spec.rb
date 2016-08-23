require 'spec_helper'

describe Api::V1::ResultsController do
	
	before :each do
		AppEventService.stub(:create)

	    # This stubs out the before_filter of application_controller
	    Api::V1::ResultsController.any_instance.stub(:log_user_activity)
	end

	describe '#create' do
		def do_create
			attrs = FactoryGirl.attributes_for :soccer_result
			post :create, api_v1_fixture_id: 1, result: attrs, format: :json
		end

		before :each do
			@fixture = FactoryGirl.build :fixture
			@fixture.division_season.scoring_system = "Soccer"
			Fixture.stub(find: @fixture)
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

			it 'read is checked and returns 200 if authed' do
				mock_ability(update: :pass)
				do_create
				response.status.should eq(200)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				Fixture.unstub :find
				do_create
				response.status.should eq(404)
			end
		end

		context 'functionality' do
			it 'does shit' do
				u = FactoryGirl.build :user
				sr = FactoryGirl.build :soccer_result

				signed_in u
				SoccerResult.should_receive(:new).and_return(sr)
				AppEventService.should_receive(:create).with(sr, u, "created", { processor: 'Ns2::Processors::ResultsProcessor' })

				do_create
				response.status.should eq(200)
			end

			it 'raises if scoring system is invalid' do
				@fixture.division_season.scoring_system = "kabaddi"
				lambda{ do_create }.should raise_error
			end

			it 'errors if the fixture already has a result' do
				@fixture.result = Result.new
				do_create
				response.status.should eq(422)
			end

			it 'errors if div does not track results' do
				@fixture.division_season.track_results = false
				do_create
				response.status.should eq(422)
			end
		end
	end


		describe '#update' do
		def do_update
			attrs = FactoryGirl.attributes_for :soccer_result
			post :update, id: 1, result: attrs, format: :json
		end

		before :each do
			@result = FactoryGirl.build :soccer_result
			Result.stub(find: @result)
			fake_ability
			signed_in
		end

		context 'authentication' do
			it 'is performed' do
				signed_out
				do_update
				response.status.should eq(401)
			end
		end

		context 'authorization' do
			it 'read is checked and returns 401 if not authed' do
				mock_ability(update: :fail)
				do_update
				response.status.should eq(401)
			end

			it 'read is checked and returns 200 if authed' do
				mock_ability(update: :pass)
				do_update
				response.status.should eq(200)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				Result.unstub :find
				do_update
				response.status.should eq(404)
			end
		end

		context 'functionality' do
			it 'does shit' do
				u = FactoryGirl.build :user

				signed_in u
				AppEventService.should_receive(:create).with(@result, u, "created", { processor: 'Ns2::Processors::ResultsProcessor' })

				@result.should_receive(:home_score=)
				@result.should_receive(:away_score=)
				do_update
				response.status.should eq(200)
			end
		end
	end
end
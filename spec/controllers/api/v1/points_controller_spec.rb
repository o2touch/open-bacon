require 'spec_helper'

describe Api::V1::PointsController do

  before :each do
    # This stubs out the before_filter of application_controller
    Api::V1::PointsController.any_instance.stub(:log_user_activity)
  end

	describe '#create' do
		def do_create(custom_attrs={})
			attrs = FactoryGirl.attributes_for :points
			attrs.merge! custom_attrs
			post :create, format: :json, api_v1_fixture_id: 1, points: attrs
		end

		before :each do
			@fixture = FactoryGirl.build :fixture
			@fixture.division.scoring_system = "Soccer"
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

			it 'read is checkout and returns 200 if authed' do
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
				@fixture.should_receive(:create_points!).and_call_original
				do_create
				response.status.should eq(200)
			end

			it 'fails if points are invalid' do
				do_create(home_points: { cat: "dog" })
				response.status.should eq(422)
			end

			it 'fails if the fixture already has points' do
				@fixture.points = Points.new
				do_create
				response.status.should eq(422)
			end

			it 'errors if div does not track results' do
				@fixture.division.track_results = false
				do_create
				response.status.should eq(422)
			end
		end
	end

	describe '#update' do
		def do_update(custom_attrs={})
			attrs = FactoryGirl.attributes_for :points
			attrs.merge! custom_attrs
			put :update, format: :json, id: 1, points: attrs
		end

		before :each do
			@points = FactoryGirl.build :points
			Points.stub(find: @points)
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

			it 'read is checkout and returns 200 if authed' do
				mock_ability(update: :pass)
				do_update
				response.status.should eq(200)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				Points.unstub :find
				do_update
				response.status.should eq(404)
			end
		end

		context 'functionality' do
			it 'does shit' do
				@points.should_receive(:update_attributes!)
				do_update
				response.status.should eq(200)
			end

			it 'fails if points are not numbers' do
				do_update(home_points: { cat: "dog" })
				response.status.should eq(422)
			end
		end
	end
end
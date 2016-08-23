require 'spec_helper'

describe Api::V1::FixturesController do

	before :each do
		# This stubs out the before_filter of application_controller
		Api::V1::FixturesController.any_instance.stub(:log_user_activity)
	end

	describe '#index' do
		before :each do
			@division = FactoryGirl.build :division_season
			@division.stub(:id).and_return(1)
			signed_in
			fake_ability
		end

		it 'returns fixtures for a division' do
			DivisionSeason.should_receive(:find_by_id).with(1).and_return(@division)
			@division.should_receive(:fixtures).and_return([])
			get :index, format: :json, division_id: @division.id
		end

		it 'returns future time filtered fixtures for a division' do
			DivisionSeason.should_receive(:find_by_id).with(1).and_return(@division)
			@division.should_receive(:future_fixtures).and_return([])
			get :index, format: :json, division_id: @division.id, when: 'future'
		end

		it 'returns future time filtered fixtures for a division' do
			DivisionSeason.should_receive(:find_by_id).with(1).and_return(@division)
			@division.should_receive(:past_fixtures).and_return([])
			get :index, format: :json, division_id: @division.id, when: 'past'
		end

		it 'errors if the division is non existant' do
			get :index, format: :json, division_id: -1
			response.status.should eq(422)
		end

		it 'errors if the time filter is non existant' do
			get :index, format: :json, division_id: @division.id, when: 'unknown'
			response.status.should eq(422)
		end

		it 'should return 200 succesful' do
			DivisionSeason.should_receive(:find_by_id).with(1).and_return(@division)
			get :index, format: :json, division_id: @division.id, when: 'past'
			response.status.should eq(200)
		end
	end

	describe '#show' do
		def do_show(id=1)
			get :show, format: :json, id: id
		end

		before :each do
			@league = FactoryGirl.build(:fixture)
			Fixture.stub(find: @fixture)
			fake_ability
		end

		context 'authentication' do
			it 'is not performed' do
				signed_out
				do_show
				response.status.should eq(200)
			end
		end

		context 'authorization' do
			it 'read is checked and returns 401 if not authed' do
				mock_ability(read: :fail)
				do_show
				response.status.should eq(401)
			end

			it 'read is checkout and returns 200 if authed' do
				mock_ability(read: :pass)
				do_show
				response.status.should eq(200)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				Fixture.unstub(:find)
				do_show
				response.status.should eq(404)
			end
		end
	end	


	# these tests are SHIT. I blame my jetlag. TS
	describe '#create' do
		before :each do
			@division = FactoryGirl.create :division_season
			signed_in
			fake_ability
		end

		def do_create(attrs=nil)
			fx = FactoryGirl.attributes_for :fixture
			fx.merge! attrs unless attrs.nil?

			post :create, fixture: fx, api_v1_division_id: 1, format: :json 
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
				mock_ability(manage: :fail)
				do_create
				response.status.should eq(401)
			end

			it 'read is checkout and returns 200 if authed' do
				mock_ability(manage: :pass)
				do_create
				response.status.should eq(200)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				post :create, fixture: {}, api_v1_division_id: 1242143234, format: :json 
				response.status.should eq(404)
			end
		end

		context 'functionality' do
			it 'does shit' do
				#shittest #needsstubbing #doyouliveinthe90s? #howevershitisfucked
				@controller.should_receive(:process_location_json)
				lambda { do_create }.should change(Fixture, :count).by(1)
				response.status.should eq(200)
			end

			# TODO: fix. TS
			# it 'sets edit_mode on the div to 1' do
			# 	@division.should_receive(:update_attributes!).with({edit_mode: 1})
			# 	do_create
			# end
		end
	end

	describe '#update' do
		before :each do
			@fixture = FactoryGirl.build :fixture
			Fixture.stub(find: @fixture)
			signed_in
			fake_ability
		end

		def do_update(attrs=nil)
			fx = FactoryGirl.attributes_for :fixture
			fx.merge! attrs unless attrs.nil?

			put :update, id: 1, fixture: fx, format: :json 
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
				Fixture.unstub(:find)
				do_update
				response.status.should eq(404)
			end
		end

		context 'functionality' do
			it 'does shit' do
				@title = "WINNN"
				do_update({title: @title})
				response.status.should eq(200)
				@fixture.reload
				@fixture.title.should eq(@title)
			end

			it 'errors if the team cannot be found' do
				do_update({home_team_id: -1})
				response.status.should eq(422)
			end
			it 'errors if the team cannot be found' do
				do_update({away_team_id: -1})
				response.status.should eq(422)
			end

			it 'does not error if the team is explicity set to nil' do
				do_update({home_team_id: nil})
				response.status.should eq(200)
			end
			it 'does not error if the team is explicity set to nil' do
				do_update({away_team_id: nil})
				response.status.should eq(200)
			end

			it 'location can be explicity set to nil' do
				@fixture.location.should_not be_nil
				@fixture.should_receive(:location=).with(nil)
				do_update({location: nil})
			end	

			it 'sets edit_mode on the div to 1' do
				@fixture.division_season.should_receive(:update_attributes!).with({edit_mode: 1})
				do_update
			end
		end
	end

	describe '#clear_edits' do
		def do_clear_edits(id=1)
			get :clear_edits, format: :json, id: id
		end

		before :each do
			@fixture = FactoryGirl.build(:fixture)
			Fixture.stub(find: @fixture)
			fake_ability
			signed_in
		end

		context 'authentication' do
			it 'is performed' do
				signed_out
				do_clear_edits
				response.status.should eq(401)
			end
		end

		context 'authorization' do
			it 'read is checked and returns 401 if not authed' do
				mock_ability(update: :fail)
				do_clear_edits
				response.status.should eq(401)
			end

			it 'read is checkout and returns 200 if authed' do
				mock_ability(update: :pass)
				do_clear_edits
				response.status.should eq(200)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				Fixture.unstub(:find)
				do_clear_edits
				response.status.should eq(404)
			end
		end

		context 'functionality' do
			it 'calls clear_edits! on the fixture' do
				@fixture.should_receive(:clear_edits!)
				do_clear_edits
			end
		end
	end

	describe '#destroy' do
		def do_destroy(id=1)
			get :destroy, format: :json, id: id
		end

		before :each do
			@fixture = FactoryGirl.build(:fixture)
			Fixture.stub(find: @fixture)
			fake_ability
			signed_in
		end

		context 'authentication' do
			it 'is performed' do
				signed_out
				do_destroy
				response.status.should eq(401)
			end
		end

		context 'authorization' do
			it 'read is checked and returns 401 if not authed' do
				mock_ability(destroy: :fail)
				do_destroy
				response.status.should eq(401)
			end

			it 'read is checkout and returns 200 if authed' do
				mock_ability(destroy: :pass)
				do_destroy
				response.status.should eq(204)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				Fixture.unstub(:find)
				do_destroy
				response.status.should eq(404)
			end
		end

		context 'functionality' do
			it 'fails if fixture not deletable' do
				@fixture.should_receive(:is_deletable?).and_return(true)
				do_destroy
			end
			it 'calls destroy! on the fixture' do
				@fixture.should_receive(:destroy)
				do_destroy
				response.status.should eq(204)
			end
		end
	end
end
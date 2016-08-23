require 'spec_helper'

describe Api::V1::DivisionSeasonsController do
	before :each do
		# This stubs out the before_filter of application_controller
		Api::V1::DivisionSeasonsController.any_instance.stub(:log_user_activity)
	end
	describe '#show' do
		def do_show(id=1)
			get :show, format: :json, id: id
		end

		before :each do
			@division = FactoryGirl.build(:division_season)
			DivisionSeason.stub(find: @division)
			fake_ability
			AppEventService.stub(:create)
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
				DivisionSeason.unstub(:find)
				do_show
				response.status.should eq(404)
			end
		end
	end	

	describe '#publish_edits' do
		def do_publish_edits(id=1)
			post :publish_edits, format: :json, id: id
		end

		before :each do
			@division = FactoryGirl.build(:division_season)
			@division.edit_mode = 1
			@division.launched = false
			DivisionSeason.stub(find: @division)
			DivisionSeason.stub(:publish_edits!)
			fake_ability
			signed_in(FactoryGirl.create(:user))
		end

		context 'authentication' do
			it 'is performed' do
				signed_out
				do_publish_edits
				response.status.should eq(401)
			end
		end

		context 'authorization' do
			it 'update is checked and returns 401 if not authed' do
				mock_ability(update: :fail)
				do_publish_edits
				response.status.should eq(401)
			end

			it 'update is checkout and returns 200 if authed' do
				mock_ability(update: :pass)
				do_publish_edits
				response.status.should eq(201)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				DivisionSeason.unstub(:find)
				do_publish_edits
				response.status.should eq(404)
			end
		end

		context 'division status' do
			it 'raises if the div is already being published' do
				@division.edit_mode = 2
				DivisionSeason.should_not_receive(:publish_edits!)
				do_publish_edits
				response.status.should eq(422)

			end
			it 'does not raise if the div has no changes to publish' do
				@division.edit_mode = 0
				DivisionSeason.should_not_receive(:publish_edits!)
				do_publish_edits
				response.status.should eq(201)
			end
			it 'calls publish_edits! if divisions has been launched' do
				@division.launched = true
				DivisionSeason.stub(delay: DivisionSeason)
				DivisionSeason.should_receive(:publish_edits!).with(1, 3)
				DivisionSeason.should_not_receive(:launch!)
				do_publish_edits
				response.status.should eq(201)
			end
			it 'calls launch! if division has not been launched' do
				DivisionSeason.stub(delay: DivisionSeason)
				DivisionSeason.should_not_receive(:publish_edits!)
				DivisionSeason.should_receive(:launch!).with(1, 3)
				do_publish_edits
				response.status.should eq(201)
			end
		end
	end

	describe '#clear' do
		def do_clear_edits(id=1)
			post :clear_edits, format: :json, id: id
		end

		before :each do
			@division = FactoryGirl.build(:division_season)
			@division.edit_mode = 1
			DivisionSeason.stub(find: @division)
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
			it 'update is checked and returns 401 if not authed' do
				mock_ability(update: :fail)
				do_clear_edits
				response.status.should eq(401)
			end

			it 'update is checkout and returns 200 if authed' do
				mock_ability(update: :pass)
				do_clear_edits
				response.status.should eq(200)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				DivisionSeason.unstub(:find)
				do_clear_edits
				response.status.should eq(404)
			end
		end

		context 'does shit' do
			it 'calls clear edits on the division' do
				@fixture = double("fixture")
				@division.should_receive(:fixtures).and_return([@fixture])
				@fixture.should_receive(:clear_edits!)
				do_clear_edits
				@division.edit_mode.should eq(0)
			end
		end
	end

	describe '#standings' do
		def do_standings(id=1)
			get :standings, format: :json, id: id
		end

		before :each do
			@division = FactoryGirl.build(:division_season)
			@division.edit_mode = 1
			DivisionSeason.stub(find: @division)
			fake_ability
			signed_in
		end
		context 'authentication' do
			it 'is not performed' do
				signed_out
				do_standings
				response.status.should eq(200)
			end
		end

		context 'authorization' do
			it 'update is checked and returns 401 if not authed' do
				mock_ability(read: :fail)
				do_standings
				response.status.should eq(401)
			end

			it 'update is checkout and returns 200 if authed' do
				mock_ability(read: :pass)
				do_standings
				response.status.should eq(200)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				DivisionSeason.unstub(:find)
				do_standings
				response.status.should eq(404)
			end
		end

		context 'does shit' do
			it 'calls clear edits on the division' do				
				response = do_standings
				JSON.parse(response.body).should == {"series" => [],"data" => {}}
			end
		end
	end
end
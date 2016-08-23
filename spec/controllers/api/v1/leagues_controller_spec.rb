require 'spec_helper'

describe Api::V1::LeaguesController do

	before :each do
	    # This stubs out the before_filter of application_controller
	    Api::V1::LeaguesController.any_instance.stub(:log_user_activity)
	 end

	describe '#index' do
	  render_views
		def do_index
			get :index, format: :json
		end

		before :each do
			@user = FactoryGirl.build :user
			controller.stub(current_user: @user)
			fake_ability
		end

		context 'authentication' do
			it 'is performed' do
				signed_out
				do_index
				response.status.should eq(401)
			end
		end

		context 'arguments' do
			let(:l1){ FactoryGirl.build :league }
			let(:l2){ FactoryGirl.build :league }

			it '422s if no such user' do
				get :index, format: :json, user_id: -1
				response.status.should eq(422)
			end

			it 'filters divisions, if required' do
				@user.should_receive(:leagues_through_teams).and_return([l1])
				d1 = FactoryGirl.create(:division_season, league: l1)
				d2 = FactoryGirl.create(:division_season, league: l1)

				team = FactoryGirl.create :team
				TeamDSService.add_team(d1, team)
				@user.stub(teams: [team])

				User.should_receive(:find_by_id).and_return @user
				get :index, format: :json, user_id: 1, filter_divisions: "blates"
				JSON.parse(response.body).first["divisions"].count.should eq(1)
				response.status.should eq(200)
			end

			it 'works' do
				@user.should_receive(:leagues_through_teams).and_return([l1, l2])
				do_index
				response.status.should eq(200)
				JSON.parse(response.body).count.should eq(2)
			end
		end
	end	

	describe '#show' do
		def do_show(id=1)
			get :show, format: :json, id: id
		end

		before :each do
			@league = FactoryGirl.build(:league)
			League.stub(find: @league)
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

			it 'read is checked and returns 200 if authed' do
				mock_ability(read: :pass)
				do_show
				response.status.should eq(200)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				League.unstub(:find)
				do_show
				response.status.should eq(404)
			end
		end
	end	
end
